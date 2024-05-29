{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoFieldSelectors #-}

module JDB.PostgreSQL.Migration
  ( runJDBMigrations,
  )
where

import Hasql.Migration
import Hasql.Pool qualified
import Hasql.Transaction
import Hasql.Transaction.Sessions qualified as TransactionSessions
import Relude

initializeSchema :: Transaction ()
initializeSchema = do
  sql $
    mconcat
      [ "create table if not exists schema_migrations ",
        "( filename varchar(512) not null",
        ", checksum varchar(32) not null",
        ", executed_at timestamptz not null default now() ",
        ");"
      ]

runMigrationFile :: (MonadIO m) => Hasql.Pool.Pool -> MigrationCommand -> m (Either Hasql.Pool.UsageError (Maybe MigrationError))
runMigrationFile pool migrationFile = do
  let migrationCommand = runMigration migrationFile
  liftIO $
    Hasql.Pool.use
      pool
      ( TransactionSessions.transaction
          TransactionSessions.Serializable
          TransactionSessions.Write
          migrationCommand
      )

runJDBMigrations :: (MonadIO m) => Hasql.Pool.Pool -> m [Either Hasql.Pool.UsageError (Maybe MigrationError)]
runJDBMigrations pool = do
  _ <-
    liftIO $
      Hasql.Pool.use
        pool
        ( TransactionSessions.transaction
            TransactionSessions.Serializable
            TransactionSessions.Write
            initializeSchema
        )

  migrations <- liftIO $ loadMigrationsFromDirectory "resources/postgresql/migrations"
  mapM (liftIO . runMigrationFile pool) migrations
