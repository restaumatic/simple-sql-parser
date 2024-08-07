
{-# LANGUAGE OverloadedStrings #-}
module Language.SQL.SimpleSQL.CreateTable where

import Language.SQL.SimpleSQL.Syntax
import Language.SQL.SimpleSQL.TestTypes
import Language.SQL.SimpleSQL.TestRunners
import Data.Text (Text)

createTableTests :: TestItem
createTableTests = Group "create table tests"
    [testStatement postgres "create table t(name text default ''::text)"
      $ CreateTable [nm "t"] [TableColumnDef (ColumnDef (nm "name") (TypeName [nm "text"])
        (Just (DefaultClause (Cast (StringLit "'" "'" "") (TypeName [nm "text"])))) [])] False
    ]
  where
    nm = Name Nothing
