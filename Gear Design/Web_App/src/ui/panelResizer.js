/**
 * Panel Resizer — Draggable splitters for left/right panel resizing.
 *
 * Creates thin drag handles between the left config panel ↔ viewport
 * and viewport ↔ right export panel.  Dragging resizes the panels in
 * real-time.  Double-click resets to defaults.
 *
 * Usage:  import { initPanelResizers } from './ui/panelResizer.js';
 *         initPanelResizers();
 */

const DEFAULTS = {
  left: 250,    // matches .panel-config width
  right: 230,   // matches .panel-export width
};

const LIMITS = {
  leftMin: 180,
  leftMax: 450,
  rightMin: 160,
  rightMax: 420,
};

/**
 * Create a single splitter handle and wire drag logic.
 * @param {'left'|'right'} side  Which panel this splitter resizes
 */
function createSplitter(side) {
  const handle = document.createElement('div');
  handle.className = `splitter-handle splitter-${side}`;
  handle.setAttribute('role', 'separator');
  handle.setAttribute('aria-orientation', 'vertical');
  handle.title = 'Drag to resize — double-click to reset';

  // Dot grip indicator
  const grip = document.createElement('div');
  grip.className = 'splitter-grip';
  grip.innerHTML = '<span></span><span></span><span></span>';
  handle.appendChild(grip);

  const panel = side === 'left'
    ? document.querySelector('.panel-config')
    : document.querySelector('.panel-export');

  if (!panel) return null;

  // Insert handle adjacent to the panel
  if (side === 'left') {
    panel.insertAdjacentElement('afterend', handle);
  } else {
    panel.insertAdjacentElement('beforebegin', handle);
  }

  let startX = 0;
  let startWidth = 0;
  let dragging = false;

  function onPointerDown(e) {
    e.preventDefault();
    dragging = true;
    startX = e.clientX;
    startWidth = panel.getBoundingClientRect().width;

    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';
    handle.classList.add('active');

    document.addEventListener('pointermove', onPointerMove);
    document.addEventListener('pointerup', onPointerUp);
  }

  function onPointerMove(e) {
    if (!dragging) return;
    const dx = e.clientX - startX;

    let newWidth;
    if (side === 'left') {
      newWidth = startWidth + dx;
    } else {
      newWidth = startWidth - dx;   // right panel grows leftward
    }

    // Clamp
    const min = side === 'left' ? LIMITS.leftMin : LIMITS.rightMin;
    const max = side === 'left' ? LIMITS.leftMax : LIMITS.rightMax;
    newWidth = Math.max(min, Math.min(max, newWidth));

    panel.style.width = newWidth + 'px';
    panel.style.minWidth = newWidth + 'px';

    // Notify 3D viewer to update aspect ratio
    window.dispatchEvent(new Event('resize'));
  }

  function onPointerUp() {
    dragging = false;
    document.body.style.cursor = '';
    document.body.style.userSelect = '';
    handle.classList.remove('active');

    document.removeEventListener('pointermove', onPointerMove);
    document.removeEventListener('pointerup', onPointerUp);
  }

  handle.addEventListener('pointerdown', onPointerDown);

  // Double-click resets to default
  handle.addEventListener('dblclick', () => {
    const def = side === 'left' ? DEFAULTS.left : DEFAULTS.right;
    panel.style.width = def + 'px';
    panel.style.minWidth = def + 'px';
    window.dispatchEvent(new Event('resize'));
  });

  return handle;
}

/**
 * Initialise both panel resizers.
 * Call once after the DOM is ready.
 */
export function initPanelResizers() {
  createSplitter('left');
  createSplitter('right');
}
