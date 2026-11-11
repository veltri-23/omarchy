(() => {
  if (location.origin !== 'https://chatgpt.com') return;
  const home = new URL(OZZIE_HOME);
  const focused = () => location.pathname === home.pathname || location.pathname.startsWith('/plugins');
  const style = document.createElement('style');
  style.id = 'ozzie-focus-style';
  style.textContent = `
    html.ozzie-focus [data-ozzie-global-sidebar],
    html.ozzie-focus #stage-slideover-sidebar,
    html.ozzie-focus #sidebar,
    html.ozzie-focus [data-testid="sidebar"],
    html.ozzie-focus nav[aria-label="Chat history"],
    html.ozzie-focus [data-testid="open-sidebar-button"],
    html.ozzie-focus [data-testid="close-sidebar-button"] { display: none !important; }
  `;
  document.documentElement.appendChild(style);
  // The web app has a global navigation rail branded ChatGPT. Identify
  // its narrow left-hand container instead of depending only
  // on framework-generated class names. Stop observing as soon as it is found.
  let observer;
  let queued = false;
  const hideNavigation = () => {
    queued = false;
    if (!focused()) return;
    if (document.querySelector('[data-ozzie-global-sidebar]')) {
      observer?.disconnect();
      return;
    }
    const navLabel = [...document.querySelectorAll('a,button,span,h1,h2,h3')].find(el =>
      el.textContent.trim() === 'ChatGPT' && el.getBoundingClientRect().left < 100);
    if (!navLabel) return;
    let candidate = null;
    for (let el = navLabel.parentElement; el && el !== document.body; el = el.parentElement) {
      const box = el.getBoundingClientRect();
      if (box.width > 420) break;
      if (box.width > 40 && box.left < 80 && box.height > innerHeight * .4) candidate = el;
    }
    if (candidate) {
      candidate.setAttribute('data-ozzie-global-sidebar', '');
      observer?.disconnect();
    }
  };
  const update = () => {
    document.documentElement.classList.toggle('ozzie-focus', focused());
    observer?.disconnect();
    if (!focused()) return;
    observer = new MutationObserver(() => {
      if (!queued) { queued = true; requestAnimationFrame(hideNavigation); }
    });
    observer.observe(document.body || document.documentElement, { childList: true, subtree: true });
    hideNavigation();
  };
  update();
  // Follow SPA navigation without scanning chat messages or running a polling timer.
  for (const name of ['pushState','replaceState']) {
    const original = history[name];
    history[name] = function(...args) { const result = original.apply(this,args); update(); return result; };
  }
  addEventListener('popstate',update);
  // Keep unrelated ChatGPT destinations out of this focused window.
  document.addEventListener('click',event => {
    const link=event.target.closest?.('a[href]');
    if(!link || event.defaultPrevented) return;
    const u=new URL(link.href,location.href);
    if(u.origin!==home.origin) return;
    const allowed=[home.pathname,'/plugins','/auth','/api/auth','/connector','/settings'];
    if(allowed.some(p=>u.pathname===p || u.pathname.startsWith(p+'/'))) return;
    if(focused()) { event.preventDefault(); event.stopImmediatePropagation(); }
  },true);
})();
