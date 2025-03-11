import { copyFileSync } from "node:fs"
import { join, resolve } from "node:path"

function syncAssets(from: string, to: string, files: string[]) {
  for (const file of files) copyFileSync(join(from, file), join(to, file))
}

// Entry point of this script.
function main() {
  const root = import.meta.dirname
  const monorepoRoot = resolve(join(root, "..", ".."))

  // Sync files from monorepo root.
  copyFileSync(join(monorepoRoot, "LICENSE"), join(root, "license.txt"))
  syncAssets(monorepoRoot, root, [".prettierrc.yaml", ".prettierignore"])
}
main()
