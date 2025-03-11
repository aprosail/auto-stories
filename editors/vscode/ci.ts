import terser from "@rollup/plugin-terser"
import typescript from "@rollup/plugin-typescript"
import { copyFileSync, readFileSync, writeFileSync } from "node:fs"
import { join, relative, resolve } from "node:path"
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
 * Compile the manifest file from package root to the output folder.
 *
 * All fields incompatible with VSCode specification and environment
 * will be removed, in order to compat the development
 * and production environment.
 *
 * @param src source folder where source package.json manifest file locates.
 * @param out out folder where output package.json manifest file should locate.
 * @param outFile the output script file as the entry of the extension.
 * This path should be an absolute path, or the relative resolution might fail.
 * @param dev whether to apply dev mode.
 * If not in dev mode, the output manifest file will be minified.
 */
function syncManifest(src: string, out: string, outFile: string, dev = false) {
  const raw = readFileSync(join(src, "package.json")).toString()
  const manifest = JSON.parse(raw)

  manifest.type = undefined
  manifest.scripts = undefined
  manifest.dependencies = undefined
  manifest.devDependencies = undefined
  manifest.main = relative(out, outFile)

  const content = dev
    ? JSON.stringify(manifest, null, 2)
    : JSON.stringify(manifest)
  writeFileSync(join(out, "package.json"), content + "\n")
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
async function main() {
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
    await build(join(src, "extension.ts"), outFile)
    syncManifest(root, out, outFile, true)
  }
}
main()
