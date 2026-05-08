const OVERLAY_ID =
  "__live_overlay";

export function showOverlay(
  message,
  title = "Live Error"
) {
  clearOverlay();

  const overlay =
    document.createElement("div");

  overlay.id = OVERLAY_ID;

  overlay.innerHTML = `
    <div class="__live_overlay_content">
      <h2>${escapeHTML(title)}</h2>
      <pre>${escapeHTML(message)}</pre>
    </div>
  `;

  Object.assign(
    overlay.style,
    styles.overlay
  );

  const content =
    overlay.querySelector(
      ".__live_overlay_content"
    );

  Object.assign(
    content.style,
    styles.content
  );

  document.documentElement.appendChild(
    overlay
  );
}

export function clearOverlay() {
  const overlay =
    document.getElementById(
      OVERLAY_ID
    );

  if (overlay) {
    overlay.remove();
  }
}

export function showStatus(message) {
  clearStatus();

  const status =
    document.createElement("div");

  status.id =
    "__live_status";

  status.textContent =
    message;

  Object.assign(
    status.style,
    styles.status
  );

  document.body.appendChild(
    status
  );

  setTimeout(() => {
    clearStatus();
  }, 2000);
}

export function clearStatus() {
  const status =
    document.getElementById(
      "__live_status"
    );

  if (status) {
    status.remove();
  }
}

function escapeHTML(text) {
  return String(text)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

const styles = {
  overlay: {
    position: "fixed",
    top: "0",
    left: "0",
    width: "100%",
    height: "100%",
    background:
      "rgba(0,0,0,0.92)",
    color: "white",
    zIndex: "999999",
    overflow: "auto",
    padding: "24px",
    boxSizing: "border-box",
    fontFamily:
      "monospace",
  },

  content: {
    maxWidth: "1200px",
    margin: "0 auto",
    whiteSpace: "pre-wrap",
    lineHeight: "1.5",
  },

  status: {
    position: "fixed",
    bottom: "16px",
    right: "16px",
    background: "#111",
    color: "#fff",
    padding:
      "8px 12px",
    borderRadius: "6px",
    fontSize: "12px",
    zIndex: "999999",
    fontFamily:
      "monospace",
  },
};
