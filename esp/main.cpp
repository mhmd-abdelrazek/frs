#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>
#include <Adafruit_Fingerprint.h>
#include <time.h>

#define RED_LED   D2
#define GREEN_LED D1
#define BLUE_LED  D0
#define BUZZER    D3

// ================= WIFI =================
const char* ssid     = "Anass";
const char* password = "55555555";

// ============== FIREBASE ===============
String projectId = "finger-reg-system";
String baseUrl   = "https://firestore.googleapis.com/v1/projects/" +
                   projectId +
                   "/databases/(default)/documents";

// =========== FINGERPRINT SENSOR =========
SoftwareSerial fingerprintSerial(12, 14);
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&fingerprintSerial);

// =============== DATA ==================
struct User {
  int    fingerprintId;
  String name;
  String nationalId;
  bool   success;
};

String lastSessionId = "";

// ============= PROTOTYPES ================
void   connectWiFi();
void   configTime();
bool   initFingerprint();
int    getFingerprintID();
String getLatestSessionId();
User   getUserWithFingerprintId(int fingerprintId);
bool   uploadAttendance(User user);
void   showSuccess(long ms, bool isUserEmpty);
void   showError(long ms);
void   showReady(long ms);

// ============= ESP BUILT-IN FUNCTIONS =================

void setup() {
  Serial.begin(115200);

  pinMode(RED_LED,   OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(BLUE_LED,  OUTPUT);
  pinMode(BUZZER,    OUTPUT);
  digitalWrite(BUZZER, LOW);

  showError(-1);

  connectWiFi();
  configTime();

  if (!initFingerprint()) {
    Serial.println("Fingerprint init failed");
    while (true);
  }

  while (lastSessionId.length() == 0) {
    lastSessionId = getLatestSessionId();
    Serial.println("Getting Session Id...");
    delay(1000);
  }

  showReady(-1);
  Serial.println("Ready.");
  Serial.println("Latest session: " + lastSessionId);
}

void loop() {
  int id = getFingerprintID();

  if (id != -1) {
    Serial.println("Fingerprint found: " + String(id));

    User user = getUserWithFingerprintId(id);

    if (user.success) {
      Serial.println("Got User: \"" + user.name + "\"");
      bool success = uploadAttendance(user);
      if (success) {
        Serial.println("Uploaded Successfully!");
        showSuccess(5000, user.name.length() == 0);
      } else {
        Serial.println("Error Uploading record!");
        showError(5000);
      }
    } else {
      Serial.println("Error Getting User!");
      showError(5000);
    }

    showReady(-1);
  }
}

// ========================================
// WIFI
// ========================================

void connectWiFi() {
  WiFi.begin(ssid, password);
  Serial.println("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected: " + WiFi.localIP().toString());
}

// ========================================
// EPOCH TIME
// ========================================

void configTime() {
  configTime(2 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  time_t now = time(nullptr);

  while (now < 100000) {
    delay(500);
    now = time(nullptr);
  }
}

// ========================================
// FINGERPRINT
// ========================================

bool initFingerprint() {
  fingerprintSerial.begin(57600);
  finger.begin(57600);
  return finger.verifyPassword();
}

int getFingerprintID() {
  uint8_t p = finger.getImage();
  if (p != FINGERPRINT_OK) return -1;

  p = finger.image2Tz();
  if (p != FINGERPRINT_OK) return -1;

  p = finger.fingerFastSearch();
  if (p != FINGERPRINT_OK) return -1;

  return finger.fingerID;
}

// ========================================
// FIRESTORE
// ========================================

String getLatestSessionId() {
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;

  String url = baseUrl + "/sessions?orderBy=start_time%20desc&pageSize=1";
  http.begin(client, url);

  int code = http.GET();
  if (code <= 0) {
    Serial.println("Session request failed: " + String(code));
    http.end();
    return "";
  }

  String response = http.getString();
  http.end();

  DynamicJsonDocument doc(8192);
  deserializeJson(doc, response);

  JsonArray documents = doc["documents"];
  if (documents.size() == 0) return "";

  String fullPath  = documents[0]["name"].as<String>();
  int    slashIndex = fullPath.lastIndexOf('/');
  return fullPath.substring(slashIndex + 1);
}

User getUserWithFingerprintId(int fingerprintId) {
  User user;
  user.fingerprintId = fingerprintId;
  user.success = false;

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;

  String url  = baseUrl + ":runQuery";
  String body = R"rawliteral(
{
  "structuredQuery": {
    "from": [{ "collectionId": "records" }],
    "where": {
      "fieldFilter": {
        "field": { "fieldPath": "fingerprint_id" },
        "op": "EQUAL",
        "value": { "integerValue": "__ID__" }
      }
    },
    "limit": 1
  }
}
)rawliteral";

  body.replace("__ID__", String(fingerprintId));

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");

  int code = http.POST(body);
  
  user.success = (code >= 200 && code < 300);
  
  String response = http.getString();
  Serial.println("User request code: " + String(code));
  Serial.println(response);

  if (!user.success) {
    Serial.println("Query failed: " + String(code));
    http.end();
    return user;
  }

  http.end();

  DynamicJsonDocument doc(8192);
  if (deserializeJson(doc, response)) return user;
  
  JsonObject firstDoc = doc[0]["document"];
  if (firstDoc.isNull()) return user;

  JsonObject fields = firstDoc["fields"];
  if (fields.isNull()) return user;

  if (fields["name"].containsKey("stringValue"))
    user.name = fields["name"]["stringValue"].as<String>();

  if (fields["national_id"].containsKey("stringValue"))
    user.nationalId = fields["national_id"]["stringValue"].as<String>();

  return user;
}

bool uploadAttendance(User user) {
  if (lastSessionId == "") {
    Serial.println("No session found");
    return false;
  }

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;

  String url  = baseUrl + "/records";
  String body = R"rawliteral(
{
  "fields": {
    "name":           { "stringValue":  "___name___"           },
    "national_id":    { "stringValue":  "___national_id___"    },
    "fingerprint_id": { "integerValue": "___fingerprint_id___" },
    "session_id":     { "stringValue":  "___session_id___"     },
    "time":           { "integerValue": "___time___"           }
  }
}
)rawliteral";

  body.replace("___name___",           user.name);
  body.replace("___national_id___",    user.nationalId);
  body.replace("___fingerprint_id___", String(user.fingerprintId));
  body.replace("___session_id___",     lastSessionId);
  body.replace("___time___", String((unsigned long)time(nullptr)));

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");

  int code = http.POST(body);
  http.end();

  return (code >= 200 && code < 300);
}

// ========================================
// FEEDBACK
// ========================================

void showReady(long ms) {
  digitalWrite(RED_LED,   LOW);
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(BLUE_LED,  HIGH);

  if (ms < 0) return;

  digitalWrite(BLUE_LED, LOW);
}

void showSuccess(long ms, bool isUserEmpty) {
  digitalWrite(BLUE_LED, LOW);
  digitalWrite(RED_LED,  LOW);
  digitalWrite(GREEN_LED, HIGH);
  digitalWrite(BUZZER, HIGH);

  if (isUserEmpty) {
    digitalWrite(BUZZER, HIGH);
    
    int i = 0;
    while (ms > 0) {
      digitalWrite(RED_LED,  LOW);
      delay(200);
      digitalWrite(RED_LED, HIGH);
      delay(200);
      
      if (i == 1) {
        digitalWrite(BUZZER, LOW);
      }
      ms -= 400;
      i++;
    }

    if (i == 0) {
      digitalWrite(BUZZER, LOW);
    }
  }
  else {
    delay(800);
    digitalWrite(BUZZER, LOW);
    if (ms > 800) delay(ms - 800);
  }
  
  digitalWrite(GREEN_LED, LOW);
}

void showError(long ms) {
  digitalWrite(BLUE_LED,  LOW);
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(RED_LED,   HIGH);

  if (ms < 0) return;

  digitalWrite(RED_LED, LOW);
}
