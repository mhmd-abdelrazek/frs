// Initialize Mermaid with dark theme
mermaid.initialize({ startOnLoad: true, theme: 'dark' });

const observer = new IntersectionObserver(entries => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.1 });
document.querySelectorAll('section').forEach(s => observer.observe(s));

const navLinks = document.querySelectorAll('.nav-pills a');
const io = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      navLinks.forEach(l => l.classList.remove('active'));
      const link = document.querySelector(`.nav-pills a[href="#${e.target.id}"]`);
      if (link) link.classList.add('active');
    }
  });
}, { threshold: 0.4 });
document.querySelectorAll('section').forEach(s => io.observe(s));

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
