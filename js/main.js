(() => {
  const toggle = document.querySelector('.menu-toggle');
  const nav = document.querySelector('.site-nav');
  const mobileQuery = window.matchMedia('(max-width: 620px)');

  if (!toggle || !nav) return;

  const setLabel = isOpen => {
    toggle.querySelector('.visually-hidden').textContent = isOpen ? 'Закрыть меню' : 'Открыть меню';
  };

  const closeMenu = ({ returnFocus = false } = {}) => {
    toggle.setAttribute('aria-expanded', 'false');
    setLabel(false);
    nav.classList.remove('is-open');
    if (returnFocus) toggle.focus();
  };

  toggle.addEventListener('click', () => {
    const isOpen = toggle.getAttribute('aria-expanded') === 'true';
    toggle.setAttribute('aria-expanded', String(!isOpen));
    setLabel(!isOpen);
    nav.classList.toggle('is-open', !isOpen);
  });

  nav.addEventListener('click', event => {
    if (event.target.closest('a')) closeMenu();
  });

  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
      closeMenu({ returnFocus: true });
    }
  });

  mobileQuery.addEventListener('change', event => {
    if (!event.matches) closeMenu();
  });
})();
