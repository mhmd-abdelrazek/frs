// Initialize Mermaid with dark theme
mermaid.initialize({ startOnLoad: true, theme: 'dark' });

const observer = new IntersectionObserver(entries => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.1 });
document.querySelectorAll('section').forEach(s => observer.observe(s));

const sections = document.querySelectorAll('section');
const navLinks = document.querySelectorAll('.nav-pills a');

function updateActiveNav() {
  let current = '';
  const scrollY = window.scrollY;

  sections.forEach(section => {
    const sectionTop = section.offsetTop;
    if (scrollY >= sectionTop - window.innerHeight / 3) {
      current = section.getAttribute('id');
    }
  });

  if (current) {
    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${current}`) {
        link.classList.add('active');
      }
    });
  }
}

window.addEventListener('scroll', updateActiveNav);
updateActiveNav();

let idleTimer;
function resetIdleTimer() {
  document.body.classList.remove('idle');
  clearTimeout(idleTimer);
  idleTimer = setTimeout(() => {
    document.body.classList.add('idle');
  }, 5000);
}

window.addEventListener('scroll', resetIdleTimer);
window.addEventListener('mousemove', resetIdleTimer);
window.addEventListener('touchstart', resetIdleTimer);
window.addEventListener('click', resetIdleTimer);

resetIdleTimer();
