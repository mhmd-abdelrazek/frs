const API_DATA = {
  "baseUrl": "https://firestore.googleapis.com/v1/projects/finger-reg-system/databases/(default)/documents",
  "esp32": [
    {
      "name": "Query User With Fingerprint ID",
      "method": "POST",
      "url": "{baseUrl}:runQuery",
      "body": {
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
      },
      "response": [
        {
          "document": {
            "name": "projects/finger-reg-system/databases/(default)/documents/records/0NhoFyR7W0doy39CamSa",
            "fields": {
              "fingerprint_id": {
                "integerValue": "8"
              },
              "national_id": {
                "stringValue": "2"
              },
              "name": {
                "stringValue": "Mohamed Abdelrazek"
              },
              "time": {
                "integerValue": "1778418209"
              },
              "session_id": {
                "stringValue": "C4hXKCAzYoxYzggoL5Mm"
              }
            },
            "createTime": "2026-05-10T13:03:31.474629Z",
            "updateTime": "2026-05-10T13:03:31.474629Z"
          },
          "readTime": "2026-05-10T15:13:12.052441Z"
        }
      ]
    },
    {
      "name": "Get Last Session",
      "method": "GET",
      "url": "{baseUrl}/sessions?orderBy=start_time%20desc&pageSize=1",
      "response": {
        "documents": [
          {
            "name": "projects/finger-reg-system/databases/(default)/documents/sessions/C4hXKCAzYoxYzggoL5Mm",
            "fields": {
              "start_time": {
                "timestampValue": "2026-05-08T20:10:45.382042Z"
              },
              "name": {
                "stringValue": "Lec 3"
              }
            },
            "createTime": "2026-05-08T20:10:46.311549Z",
            "updateTime": "2026-05-08T20:10:46.311549Z"
          }
        ],
        "nextPageToken": "AFTOeJzkhsEGyE0ouqzU"
      }
    },
    {
      "name": "Save Attendance Record",
      "method": "POST",
      "url": "{baseUrl}/records",
      "body": {
        "fields": {
          "name":           { "stringValue":  "___name___"           },
          "national_id":    { "stringValue":  "___national_id___"    },
          "fingerprint_id": { "integerValue": "___fingerprint_id___" },
          "session_id":     { "stringValue":  "___session_id___"     },
          "time":           { "integerValue": "___time___"           }
        }
      },
      "response": {
        "name": "projects/finger-reg-system/databases/(default)/documents/records/T3zaPUb0VTD57KB2IxT4",
        "fields": {
          "fingerprint_id": {
            "integerValue": "4"
          },
          "name": {
            "stringValue": "Anas Mohamed"
          },
          "national_id": {
            "stringValue": "2"
          },
          "session_id": {
            "stringValue": "C4hXKCAzYoxYzggoL5Mm"
          },
          "time": {
            "integerValue": "1778418209"
          }
        },
        "createTime": "2026-05-10T15:22:40.124464Z",
        "updateTime": "2026-05-10T15:22:40.124464Z"
      }
    }
  ],
  "mobile": []
};
