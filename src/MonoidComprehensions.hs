module MonoidComprehensions (plugin) where

import qualified Data.Generics as G
import qualified GhcPlugins    as P
import qualified HsSyn         as S
import qualified SrcLoc        as L

--------------------------------------------------------------------------------
-- Main definitions
--------------------------------------------------------------------------------

plugin :: P.Plugin
plugin = P.defaultPlugin
  { P.parsedResultAction = \_opts _summary -> pure . desugarMod
  , P.pluginRecompile = P.purePlugin }

desugarMod :: P.HsParsedModule -> P.HsParsedModule
desugarMod hpm =
  hpm { P.hpm_module = G.everywhere (G.mkT desugarExpr) $ P.hpm_module hpm }

desugarExpr :: S.LHsExpr S.GhcPs -> S.LHsExpr S.GhcPs
desugarExpr (L.L ps (S.HsPar px (L.L cs (S.HsDo dx ctx (L.L ss stmts)))))
  | S.isListCompExpr ctx, ps `wraps` cs =
    L.L ps . S.HsPar px . foldExpr . L.L cs . S.HsDo dx ctx
    . L.L ss $ desugarStmt <$> stmts
desugarExpr expr = expr

desugarStmt :: S.ExprLStmt S.GhcPs -> S.ExprLStmt S.GhcPs
desugarStmt (L.L ss (S.BindStmt sx pat body bind' fail')) =
  L.L ss $ S.BindStmt sx pat (toListExpr body) bind' fail'
desugarStmt stmt = stmt

--------------------------------------------------------------------------------
-- Expression helpers
--------------------------------------------------------------------------------

foldExpr :: S.LHsExpr S.GhcPs -> S.LHsExpr S.GhcPs
foldExpr = mkFunExpr "Data.Foldable" "fold"

toListExpr :: S.LHsExpr S.GhcPs -> S.LHsExpr S.GhcPs
toListExpr = mkFunExpr "Data.Foldable" "toList"

mkFunExpr :: String -> String -> S.LHsExpr S.GhcPs -> S.LHsExpr S.GhcPs
mkFunExpr modName funName arg = loc $ app (loc . var $ loc fun) arg
  where fun = P.mkRdrQual (P.mkModuleName modName) (P.mkVarOcc funName)
        loc = L.L P.noSrcSpan -- TODO: better SrcSpan
        app = S.HsApp S.noExt
        var = S.HsVar S.noExt

--------------------------------------------------------------------------------
-- `SrcSpan` helpers
--------------------------------------------------------------------------------

-- TODO: Pattern synonym?
wraps :: L.SrcSpan -> L.SrcSpan -> Bool
wraps ss1 ss2 =
     L.srcSpanStart ss1 `nextTo` L.srcSpanStart ss2
  && L.srcSpanEnd   ss2 `nextTo` L.srcSpanEnd   ss1

nextTo :: L.SrcLoc -> L.SrcLoc -> Bool
nextTo (L.RealSrcLoc rsl1) (L.RealSrcLoc rsl2) =
     L.srcLocLine rsl1     == L.srcLocLine rsl2
  && L.srcLocCol  rsl1 + 1 == L.srcLocCol  rsl2
nextTo _ _ = False
