import terser from "@rollup/plugin-terser"
import typescript from "@rollup/plugin-typescript"
import { copyFileSync } from "node:fs"
import { join, resolve } from "node:path"
import { argv } from "node:process"
import { rollup } from "rollup"

/**
 * Compile and minify all the script of the extension.
 *
 * @param src source ts file as the entry of the extension.
 * @param out output compiled and minified script file.
 */
async function build(src: string, out: string) {
  const bundle = await rollup({
    plugins: [typescript(), terser()],
    input: src,
    external(source, _importer, isResolved) {
      if (isResolved) return false
      return source === "vscode" || source.startsWith("node:")
    },
  })
  await bundle.write({ file: out, format: "commonjs" })
}

/**
 * Sync some files from a folder to another folder.
 *
 * @param from folder containing files to sync from.
 * @param to folder containing files to sync into.
 * @param files relative paths of the files to sync.
 */
function syncAssets(from: string, to: string, files: string[]) {
  for (const file of files) copyFileSync(join(from, file), join(to, file))
}

// Entry point of this script.
function main() {
  const root = import.meta.dirname
  const src = join(root, "src")
  const out = join(root, "out")
  const outFile = join(out, "extension.js")
  const monorepoRoot = resolve(join(root, "..", ".."))

  // Sync files from monorepo root.
  copyFileSync(join(monorepoRoot, "LICENSE"), join(root, "license.txt"))
  syncAssets(monorepoRoot, root, [".prettierrc.yaml", ".prettierignore"])

  // Compile and build manifest if necessary.
  if (argv.includes("build")) {
    build(join(src, "extension.ts"), outFile)
  }
}
main()
