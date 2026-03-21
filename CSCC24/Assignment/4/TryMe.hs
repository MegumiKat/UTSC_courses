module TryMe where

import Data.List qualified as List
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Prelude hiding (pure, (>>=))
import TryMeDef

instance TryMeModel TC where
    pure :: a -> TC a
    pure a = MkTC (\s -> (s, Right a))

    (>>=) :: TC a -> (a -> TC b) -> TC b
    MkTC stf >>= k = MkTC $ \s ->
        let (s', result) = stf s
        in case result of
            Left e  -> (s', Left e)
            Right a -> unTC (k a) s'

    raise :: Exception -> TC a
    raise e = MkTC $ \s -> (s, Left e)

    reifyException :: TC a -> TC (Either Exception a)
    reifyException (MkTC stf1) = MkTC $ \s -> 
        let (s', result) = stf1 s 
        in case result of
            Left e  -> (s', Right (Left e))
            Right a -> (s', Right (Right a))


    putVar :: String -> Integer -> TC ()
    putVar v x = MkTC $ \s -> (Map.insert v x s, Right ())

    getVar :: String -> TC Integer
    getVar v = MkTC $ \s ->
        case Map.lookup v s of
            Just x  -> (s, Right x)
            Nothing -> (s, Left VarUninit)

run :: Stmt -> (Map String Integer, Either Exception ())
run stmt = runWith stmt Map.empty

runWith :: Stmt -> Map String Integer -> (Map String Integer, Either Exception ())
runWith stmt s0 = unTC (interp stmt) s0

eval :: TryMeModel m => Expr -> m Integer
eval (Lit i) = pure i
eval (Var v) = getVar v
eval (Add e1 e2) =
    eval e1 >>= \v1 ->
    eval e2 >>= \v2 ->
    pure (v1 + v2)
eval (Div e1 e2) = 
    eval e1 >>= \v1 ->
    eval e2 >>= \v2 ->
    if v2 == 0
        then raise DivByZero
        else pure (v1 `div` v2)

interp :: TryMeModel m => Stmt -> m ()
interp (Assign v e) = 
    eval e >>= \x ->
    putVar v x
interp (Compound stmts) = interpCompound stmts
interp (Try stmts handlers) =
    reifyException (interpCompound stmts) >>= \result ->
    case result of
        Right _ -> pure ()
        Left ex -> handleException ex handlers

handleException :: TryMeModel m => Exception -> [(Exception, [Stmt])] -> m ()
handleException ex handlers =
    case List.find (\(ex', _) -> ex == ex') handlers of
        Just (_, handlerStmts) -> interpCompound handlerStmts
        Nothing -> raise ex

interpCompound :: TryMeModel m => [Stmt] -> m ()
interpCompound [] = pure ()
interpCompound (stmt:stmts) =
    interp stmt >>= \_ ->
    interpCompound stmts