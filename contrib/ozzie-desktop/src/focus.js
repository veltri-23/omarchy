(() => {
  if (location.origin !== 'https://chatgpt.com') return;
  const home = new URL(OZZIE_HOME);
  const focused = () => location.pathname === home.pathname || location.pathname.startsWith('/plugins');
  const style = document.createElement('style');
  style.id = 'ozzie-focus-style';
  style.textContent = `
    html.ozzie-focus #stage-slideover-sidebar,
    html.ozzie-focus #sidebar,
    html.ozzie-focus [data-testid="sidebar"],
    html.ozzie-focus nav[aria-label="Chat history"],
    html.ozzie-focus [data-testid="open-sidebar-button"],
    html.ozzie-focus [data-testid="close-sidebar-button"] { display: none !important; }
  `;
  document.documentElement.appendChild(style);
  const update = () => document.documentElement.classList.toggle('ozzie-focus', focused());
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
