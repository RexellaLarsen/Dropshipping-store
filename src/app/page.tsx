import { ArrowRight, ShoppingBag, Sparkles } from "lucide-react";

const products = [
  { name: "Arc Desk Lamp", category: "Workspace", price: "$48.00", image: "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=900&q=85" },
  { name: "Everyday Carry Tote", category: "On the go", price: "$32.00", image: "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=85" },
  { name: "Stoneware Pour Set", category: "Kitchen", price: "$56.00", image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=85" },
  { name: "Cloud Knit Throw", category: "Living", price: "$74.00", image: "https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=900&q=85" },
];

export default function Home() {
  return (
    <main className="min-h-screen bg-[#f7f8f4] text-[#20372d]">
      <div className="flex min-h-9 items-center justify-center gap-2 bg-[#1d3f33] px-4 text-center text-xs text-white">
        <Sparkles size={14} /> Thoughtful finds for everyday living
      </div>
      <header className="mx-auto flex max-w-7xl items-center justify-between px-5 py-6">
        <a href="#" className="text-2xl font-semibold tracking-tight">OctraStore</a>
        <nav className="hidden gap-7 text-sm sm:flex">
          <a href="#shop">Shop</a><a href="#about">About</a>
        </nav>
        <a href="#shop" className="flex items-center gap-2 text-sm"><ShoppingBag size={18} /> Shop now</a>
      </header>
      <section className="mx-auto grid max-w-7xl gap-8 px-5 pb-16 pt-8 md:grid-cols-2 md:items-center md:pb-24">
        <div>
          <p className="mb-5 text-xs font-semibold uppercase tracking-[.2em] text-[#78917f]">The everyday collection</p>
          <h1 className="max-w-xl text-5xl font-medium leading-[1.05] tracking-tight sm:text-7xl">Good finds.<br /><span className="text-[#78917f]">Better days.</span></h1>
          <p className="mt-6 max-w-md leading-7 text-[#65736c]">Useful, thoughtfully chosen essentials to make everyday moments feel a little better.</p>
          <a href="#shop" className="mt-8 inline-flex items-center gap-3 rounded-full bg-[#285b48] px-6 py-4 text-sm font-medium text-white">Explore the collection <ArrowRight size={17} /></a>
        </div>
        <div className="overflow-hidden rounded-[2rem] bg-[#e5e8df]">
          <img src="https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1500&q=90" alt="Thoughtfully styled living space" className="h-[360px] w-full object-cover md:h-[520px]" />
        </div>
      </section>
      <section id="shop" className="mx-auto max-w-7xl px-5 py-16 md:py-20">
        <div className="mb-8 flex items-end justify-between">
          <div><p className="mb-3 text-xs font-semibold uppercase tracking-[.2em] text-[#78917f]">The current collection</p><h2 className="text-3xl tracking-tight md:text-5xl">Everyday, elevated.</h2></div>
          <span className="text-sm text-[#65736c]">4 featured finds</span>
        </div>
        <div className="grid grid-cols-2 gap-4 md:grid-cols-4 md:gap-6">
          {products.map((product) => (
            <article key={product.name}>
              <div className="mb-4 aspect-[4/5] overflow-hidden rounded-2xl bg-[#e5e3d8]">
                <img src={product.image} alt={product.name} className="h-full w-full object-cover transition duration-300 hover:scale-105" />
              </div>
              <p className="text-xs uppercase tracking-wider text-[#829087]">{product.category}</p>
              <h3 className="mt-1 text-sm font-medium md:text-base">{product.name}</h3>
              <p className="mt-2 text-sm">{product.price}</p>
            </article>
          ))}
        </div>
      </section>
      <section id="about" className="bg-[#e8ede5] px-5 py-16 text-center md:py-20">
        <p className="text-xs font-semibold uppercase tracking-[.2em] text-[#78917f]">A more considered way</p>
        <h2 className="mt-4 text-4xl tracking-tight md:text-6xl">Less noise. More meaning.</h2>
        <p className="mx-auto mt-5 max-w-xl leading-7 text-[#65736c]">OctraStore brings together practical pieces with thoughtful details, chosen to make everyday living feel easier and more intentional.</p>
      </section>
      <footer className="bg-[#1d3f33] px-5 py-8 text-center text-sm text-white">© 2026 OctraStore. Thoughtful finds for everyday living.</footer>
    </main>
  );
}
