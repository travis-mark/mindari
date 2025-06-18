#!/usr/bin/env bash
set -o errexit

DATABASE_URL=ecto://postgres:hasta-railroad-sailors@localhost/mindari_dev SECRET_KEY_BASE=Lmfw3Xn30OW5aXGX8AMDDMv/sN2+DH06AVKDwi9kRJaGKmu+7XIhEFBScT4FDSnX _build/prod/rel/mindari/bin/server