-- LazyVim's editor/refactoring extra hasn't been updated for refactoring.nvim's
-- 2026-04-20 commit (f06ac3d) that added `require "async"` to refactoring.lua.
-- The `async` module comes from lewis6991/async.nvim per upstream's README.
-- Without this dep, `Failed to run config for refactoring.nvim — module 'async' not found`.
return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = { "lewis6991/async.nvim" },
}
