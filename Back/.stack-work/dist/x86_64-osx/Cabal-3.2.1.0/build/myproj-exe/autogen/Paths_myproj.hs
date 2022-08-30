{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_myproj (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/caotic/Desktop/Projects/App/Back/.stack-work/install/x86_64-osx/c72b47847b153c38db8ae2b3582ad077bca9475f96439c44785a37cbc2656924/8.10.7/bin"
libdir     = "/Users/caotic/Desktop/Projects/App/Back/.stack-work/install/x86_64-osx/c72b47847b153c38db8ae2b3582ad077bca9475f96439c44785a37cbc2656924/8.10.7/lib/x86_64-osx-ghc-8.10.7/myproj-0.1.0.0-EefSOqOEuBeVPQPlC5auF-myproj-exe"
dynlibdir  = "/Users/caotic/Desktop/Projects/App/Back/.stack-work/install/x86_64-osx/c72b47847b153c38db8ae2b3582ad077bca9475f96439c44785a37cbc2656924/8.10.7/lib/x86_64-osx-ghc-8.10.7"
datadir    = "/Users/caotic/Desktop/Projects/App/Back/.stack-work/install/x86_64-osx/c72b47847b153c38db8ae2b3582ad077bca9475f96439c44785a37cbc2656924/8.10.7/share/x86_64-osx-ghc-8.10.7/myproj-0.1.0.0"
libexecdir = "/Users/caotic/Desktop/Projects/App/Back/.stack-work/install/x86_64-osx/c72b47847b153c38db8ae2b3582ad077bca9475f96439c44785a37cbc2656924/8.10.7/libexec/x86_64-osx-ghc-8.10.7/myproj-0.1.0.0"
sysconfdir = "/Users/caotic/Desktop/Projects/App/Back/.stack-work/install/x86_64-osx/c72b47847b153c38db8ae2b3582ad077bca9475f96439c44785a37cbc2656924/8.10.7/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "myproj_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "myproj_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "myproj_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "myproj_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "myproj_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "myproj_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
