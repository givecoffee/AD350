document.addEventListener('DOMContentLoaded', function () {

  /* ----------------------------------------------------------
     1. ACTIVE NAV HIGHLIGHTING
     Matches data-page attribute against current filename.
  ---------------------------------------------------------- */
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('nav a[data-page]').forEach(function (link) {
    if (link.dataset.page === currentPage) {
      link.classList.add('active');
    }
  });


  /* ----------------------------------------------------------
     2. MOBILE SIDEBAR TOGGLE
  ---------------------------------------------------------- */
  const toggle  = document.querySelector('.menu-toggle');
  const sidebar = document.querySelector('aside');

  if (toggle && sidebar) {
    toggle.addEventListener('click', function (e) {
      e.stopPropagation();
      sidebar.classList.toggle('open');
    });

    document.addEventListener('click', function (e) {
      if (
        window.innerWidth <= 900 &&
        sidebar.classList.contains('open') &&
        !sidebar.contains(e.target) &&
        !toggle.contains(e.target)
      ) {
        sidebar.classList.remove('open');
      }
    });
  }


  /* ----------------------------------------------------------
     3. ASSIGNMENT ACCORDION
     Clicking an item-header toggles its expanded state.
     Only one item open at a time. Links inside headers are
     excluded from triggering the toggle.
  ---------------------------------------------------------- */
  const itemHeaders = document.querySelectorAll('.item-header');

  itemHeaders.forEach(function (header) {
    header.addEventListener('click', function (e) {
      if (e.target.tagName === 'A' || e.target.closest('a')) return;

      const item = this.closest('.expandable-item');
      const isExpanded = item.classList.contains('expanded');

      // Close all
      document.querySelectorAll('.expandable-item.expanded').forEach(function (open) {
        open.classList.remove('expanded');
      });

      // Re-open if it wasn't already open
      if (!isExpanded) {
        item.classList.add('expanded');
      }
    });
  });

  const expandAll  = document.querySelector('.expand-all');
  const collapseAll = document.querySelector('.collapse-all');

  if (expandAll) {
    expandAll.addEventListener('click', function () {
      document.querySelectorAll('.expandable-item').forEach(function (item) {
        item.classList.add('expanded');
      });
    });
  }

  if (collapseAll) {
    collapseAll.addEventListener('click', function () {
      document.querySelectorAll('.expandable-item').forEach(function (item) {
        item.classList.remove('expanded');
      });
    });
  }

});