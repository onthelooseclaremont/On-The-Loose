// ============================================================
// Fill these in after creating your free Supabase project:
// Supabase dashboard → Project Settings → API
//   - "Project URL"        → SUPABASE_URL
//   - "anon" "public" key  → SUPABASE_ANON_KEY
// (The anon key is safe to expose in frontend code — that's what it's for.
//  Row Level Security in schema.sql controls what it's allowed to do.)
// ============================================================
const SUPABASE_URL = "https://fijdmarhgopprqlvxomh.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpamRtYXJoZ29wcHJxbHZ4b21oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUzMzc0MjEsImV4cCI6MjEwMDkxMzQyMX0._1tqtvikdcJM0UBwoneH3epZ-sDN5Zsp1O5Eqc9TZW0";

const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
