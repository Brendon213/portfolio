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

(() => {
  const slider = document.querySelector('.project-slider');
  if (!slider) return;

  const cards = Array.from(slider.querySelectorAll('.project-slides > .project-card'));
  const currentLabel = slider.querySelector('.project-current');
  const totalLabel = slider.querySelector('.project-total');
  const previous = slider.querySelector('.project-arrow-prev');
  const next = slider.querySelector('.project-arrow-next');
  let current = 0;

  if (cards.length < 2) return;
  totalLabel.textContent = String(cards.length);

  const show = index => {
    current = (index + cards.length) % cards.length;
    cards.forEach((card, cardIndex) => { card.hidden = cardIndex !== current; });
    currentLabel.textContent = String(current + 1);
  };

  previous.addEventListener('click', () => show(current - 1));
  next.addEventListener('click', () => show(current + 1));
  show(0);
})();
