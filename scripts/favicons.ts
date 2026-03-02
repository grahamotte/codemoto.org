import { execSync } from "child_process";
import { copyFileSync, mkdirSync, writeFileSync } from "fs";
import { join } from "path";
import { pathToFileURL } from "url";

type IconChild = [string, Record<string, string | number>, IconChild[]?];

function attrsToString(attrs: Record<string, string | number>): string {
  return Object.entries(attrs)
    .map(([k, v]) => `${k}="${String(v).replace(/"/g, "&quot;")}"`)
    .join(" ");
}

function childToString(node: IconChild): string {
  const [tag, attrs, children] = node;
  const str = attrsToString(attrs);
  if (children?.length) {
    return `<${tag} ${str}>${children.map(childToString).join("")}</${tag}>`;
  }
  return `<${tag} ${str}/>`;
}

function buildSvg(iconChildren: IconChild[]): string {
  const attrs = attrsToString({
    xmlns: "http://www.w3.org/2000/svg",
    width: 24,
    height: 24,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "black",
    "stroke-width": 2,
    "stroke-linecap": "round",
    "stroke-linejoin": "round",
  });
  return `<svg ${attrs}>\n${iconChildren.map(childToString).join("\n")}\n</svg>\n`;
}

const repoRoot = join(import.meta.dir, "..");
const imageDir = join(repoRoot, "frontend", "public", "images");
const iconsDir = join(
  repoRoot,
  "frontend",
  "node_modules",
  "lucide",
  "dist",
  "esm",
  "lucide",
  "src",
  "icons",
);

async function generate(name: string, icon: string) {
  const mod = await import(pathToFileURL(join(iconsDir, `${icon}.js`)).href);
  const svg = buildSvg(mod.default as IconChild[]);

  mkdirSync(imageDir, { recursive: true });

  const svgPath = join(imageDir, `${name}.svg`);
  writeFileSync(svgPath, svg);
  console.log(`  ${name}.svg`);

  for (const size of [16, 32, 96, 180, 192, 512]) {
    const pngPath = join(imageDir, `${name}-${size}.png`);
    const jpgPath = join(imageDir, `${name}-${size}.jpg`);
    execSync(
      `rsvg-convert -w ${size} -h ${size} "${svgPath}" > "${pngPath}"`,
      { stdio: "inherit", shell: "/bin/zsh" },
    );
    console.log(`  ${name}-${size}.png`);
    execSync(
      `magick "${pngPath}" -background white -flatten "${jpgPath}"`,
      { stdio: "inherit" },
    );
    console.log(`  ${name}-${size}.jpg`);
  }

  const icoPath = join(imageDir, `${name}.ico`);
  const png512 = join(imageDir, `${name}-512.png`);
  execSync(
    `ffmpeg -y -loglevel error -i "${png512}" -filter_complex "[0:v]scale=64:64:flags=lanczos[v64];[0:v]scale=32:32:flags=lanczos[v32];[0:v]scale=16:16:flags=lanczos[v16]" -map "[v64]" -map "[v32]" -map "[v16]" "${icoPath}"`,
    { stdio: "inherit" },
  );
  console.log(`  ${name}.ico`);

  const publicDir = join(repoRoot, "frontend", "public");
  const rootFaviconPath = join(publicDir, "favicon.ico");
  copyFileSync(icoPath, rootFaviconPath);
  console.log(`  favicon.ico (root)`);

  const webmanifest = {
    name,
    short_name: name,
    icons: [
      { src: `/images/${name}-192.png`, sizes: "192x192", type: "image/png" },
      { src: `/images/${name}-512.png`, sizes: "512x512", type: "image/png" },
    ],
    start_url: "/",
    display: "standalone",
    background_color: "#ffffff",
    theme_color: "#ffffff",
  };
  const manifestPath = join(publicDir, `${name}.webmanifest`);
  writeFileSync(manifestPath, JSON.stringify(webmanifest, null, 2) + "\n");
  console.log(`  ${name}.webmanifest`);
}

const args = process.argv.slice(2);
if (args.length < 1 || args.length > 2) {
  console.error("Usage: bun run scripts/favicons.ts <lucide-icon> [name]");
  console.error("  lucide-icon: kebab-case icon name (e.g. heart, chess-queen)");
  console.error("  name: output file prefix (defaults to lucide-icon name)");
  process.exit(1);
}

const icon = args[0];
const name = args[1] ?? icon;
await generate(name, icon);
console.log(`\nDone: ${name} (${icon})`);
