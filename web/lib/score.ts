const OBSCURITY_URL = process.env.OBSCURITY_URL ?? "http://localhost:8080";

export async function getScore(word: string): Promise<number | null> {
  try {
    const res = await fetch(`${OBSCURITY_URL}/score/${encodeURIComponent(word)}`, {
      cache: "no-store",
    });
    if (!res.ok) return null;
    const data = await res.json();
    return typeof data.score === "number" ? data.score : null; // okay cool ternary conditional I'm diggin it.
  } catch {
    return null;
  }
}

