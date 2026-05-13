// ============ ACTIVE NAV HIGHLIGHTING ============
// Determines the current page from the URL and adds .active to the matching nav link.
(function () {
  const path = window.location.pathname.split('/').pop() || 'index.html';
  const links = document.querySelectorAll('nav a[data-page]');
  links.forEach(link => {
    if (link.dataset.page === path) {
      link.classList.add('active');
    }
  });
})();

// ============ MOBILE MENU ============
(function () {
  const toggle = document.querySelector('.menu-toggle');
  const sidebar = document.querySelector('aside');
  if (!toggle || !sidebar) return;

  toggle.addEventListener('click', (e) => {
    e.stopPropagation();
    sidebar.classList.toggle('open');
  });

  document.addEventListener('click', (e) => {
    if (window.innerWidth <= 900 &&
        sidebar.classList.contains('open') &&
        !sidebar.contains(e.target) &&
        !toggle.contains(e.target)) {
      sidebar.classList.remove('open');
    }
  });
})();
