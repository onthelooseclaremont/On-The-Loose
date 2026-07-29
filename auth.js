// ============================================================
// Shared auth logic — include on any page after supabase-config.js
// Expects a <span id="auth-status"></span> somewhere in the nav.
// ============================================================

async function otlCurrentUser() {
  const { data: { session } } = await sb.auth.getSession();
  return session ? session.user : null;
}

async function otlSignUp(email, password, name) {
  const { data, error } = await sb.auth.signUp({
    email, password,
    options: { data: { name: name } }
  });
  return { data, error };
}

async function otlSignIn(email, password) {
  const { data, error } = await sb.auth.signInWithPassword({ email, password });
  return { data, error };
}

async function otlSignOut() {
  await sb.auth.signOut();
  window.location.href = "index.html";
}

// Renders the little "Log In" / "Hi, Name — Log out" widget in the header
async function otlRenderAuthStatus() {
  const el = document.getElementById("auth-status");
  if (!el) return;

  const user = await otlCurrentUser();
  if (user) {
    let name = user.email;
    const { data: profile } = await sb.from("profiles").select("name").eq("id", user.id).single();
    if (profile && profile.name) name = profile.name;

    el.innerHTML = `<span class="mono" style="font-size:12px;">${name}</span> · <a href="#" id="otl-logout-link" class="mono" style="font-size:12px;">Log out</a>`;
    document.getElementById("otl-logout-link").addEventListener("click", function (e) {
      e.preventDefault();
      otlSignOut();
    });
  } else {
    el.innerHTML = `<a href="account.html" class="mono" style="font-size:12px;">Log In</a>`;
  }
}

document.addEventListener("DOMContentLoaded", otlRenderAuthStatus);
