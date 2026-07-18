import { db } from "@/db";
import { words } from "@/db/schema";


export default async function Home() {
  const allWords = await db.select().from(words);
  return (
    <main className="max-w-2xl mx-auto p-8">
      <h1 className="text-3xl font-bold mb-2">Roborean</h1>
      <p className="text-sm test-gray-500 mb-6">{allWords.length} words saved</p>
      <ul className="space-y-3">
        {allWords.map((entry) => (
          <li key={entry.id} className="p-4 rounded-lg border border-gray-200">
            <strong className="text-lg font-semibold">{entry.word}</strong>: 
            <p className="text-gray-600">{entry.meaning}</p>
          </li>
        ))}
      </ul>
    </main>
  );
}
