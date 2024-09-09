This provides an exclusion lock capability to help make sure that two instances of a program don't run at the same time.

Provides lockme(<filename>) to set lock. This will fail if the lock by that name exists.

unlockme(<filename>) will remove the file and thus unset the lock.

