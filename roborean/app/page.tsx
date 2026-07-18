import { db } from "@/db";
import { words } from "@/db/schema";


export default async function Home() {
  const allWords = await db.select().from(words);
  return (
    <main>
      <h1>Roborean</h1>
      <p>{allWords.length} words saved</p>
      <ul>
        {allWords.map((entry) => (
          <li key={entry.id}>
            <strong>{entry.word}</strong>: {entry.meaning}
          </li>
        ))}
      </ul>
    </main>
  );
}
