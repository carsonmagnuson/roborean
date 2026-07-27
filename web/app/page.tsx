import WordGame from "./word-game";

export default function Home() {
  return (
    <main className="max-w-2xl mx-auto p-4 sm:p-8">
      <h1 className="text-6xl sm:text-6xl md:text-8xl font-serif mb-2">ROBOREAN</h1>
      <p className="text-sm text-gray-500 mb-6 justify-center">
        How obscure is your vocabulary?
      </p>
      <WordGame />
    </main>
  );
}

