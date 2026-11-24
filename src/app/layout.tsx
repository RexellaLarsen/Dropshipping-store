import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Field & Form — Considered goods for everyday living",
  description: "Thoughtfully selected essentials for the way you live, work, and move.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
