-- TRANSIENT OVERRIDE — drop this file after the next LazyVim release.
--
-- refactoring.nvim 2026-04-20 commit f06ac3d added `require "async"` (now
-- depends on lewis6991/async.nvim per upstream README). LazyVim merged the
-- corresponding spec update in PR #7124 on 2026-04-22, but it sits on `main`
-- — no release has been tagged since v15.15.0 (2026-04-02). lazy.nvim
-- follows tags by default, so we're missing the fix until a new tag drops.
--
-- When LazyVim ships v15.16.x or later, `:Lazy update LazyVim` will pull in
-- the upstream fix, and this override can be deleted.
return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = { "lewis6991/async.nvim" },
}
