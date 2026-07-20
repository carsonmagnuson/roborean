import { db } from "@/db";
import { words } from "@/db/schema";
import { addWord, deleteWord } from "./actions";

export const dynamic = "force-dynamic"; //to obviate the query-prerendering issue, apparently.

export default async function Home() {
  const allWords = await db.select().from(words);
  return (
    <main className="max-w-2xl mx-auto p-8">
      <h1 className="text-3xl font-bold mb-2">Roborean</h1>
      <p className="text-sm test-gray-500 mb-6">{allWords.length} words saved</p>
      <form action={addWord} className="mb-8 flex flex-col gap-2">
        <input
          name="word"
          placeholder="word"
          required
          className="border border-gray-300 rounded p-2"
        />
        <input
          name="meaning"
          placeholder="meaning"
          required
          className="border border-gray-300 rounded p-2"
        />
        <button
          type="submit"
          className="bg-gray-900 text-white hover:bg-gray-600 rounded p-2 font-semibold"
        >
          Add word
        </button>
      </form>
      <ul className="space-y-3">
        {allWords.map((entry) => (
          <li
            key={entry.id}
            className="p-4 rounded-lg border border-gray-200 flex items-start justify-between gap-4">
            <div>
              <strong className="text-lg font-semibold">{entry.word}</strong>:
              <p className="text-gray-600">{entry.meaning}</p>
            </div>
            <form action={deleteWord}>
              <input type="hidden" name="id" value={entry.id} />
              <button
                type="submit"
                className="text-sm text-red-600 hover:text-red-800">
                delete
              </button>
            </form>
          </li>
        ))}
      </ul>
    </main>
  );
};
