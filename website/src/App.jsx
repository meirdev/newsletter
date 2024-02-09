import { useState } from "react";

const { apiUrl } = window.wingEnv;

function App() {
  const [email, setEmail] = useState("");

  const [message, setMessage] = useState("");

  const onSubmit = async (event) => {
    event.preventDefault();

    try {
      await fetch(apiUrl + "/subscribe", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ emailAddress: email }),
      });

      setMessage("Thanks you.");
    } catch {
      setMessage("Error, try again.");
    }
  };

  return (
    <div className="flex flex-col items-center justify-center h-screen">
      <div>
        <img src="/image.jpg" className="w-[600px] h-[300px]" />
      </div>
      <div className="w-[600px] text-center p-8 bg-neutral-900 border-t border-neutral-600">
        <h1 className="text-3xl font-bold text-white">
          Unlock Limitless Possibilities
        </h1>
        <p className="text-lg leading-8 mt-4 text-neutral-400">
          Gain premium access to tutorials, updates, and a thriving community.
          Supercharge your coding journey today with our subscription!
        </p>
        <div className="mt-4">
          {message === "" ? (
            <form onSubmit={onSubmit}>
              <input
                type="email"
                name="email"
                placeholder="Enter your email"
                required
                className="rounded-full px-6 mx-1"
                onChange={(e) => setEmail(e.target.value)}
              />
              <button
                type="submit"
                className="text-white py-2 px-4 mx-1 rounded-full bg-gradient-to-r from-fuchsia-500 to-pink-500"
              >
                Subscribe
              </button>
            </form>
          ) : (
            <div className="text-white">{message}</div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
