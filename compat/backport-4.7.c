/*
 * Copyright(c) 2016 Hauke Mehrtens <hauke@hauke-m.de>
 *
 * Backport functionality introduced in Linux 4.7.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/export.h>
#include <linux/list.h>
#include <linux/rcupdate.h>
#include <linux/rhashtable.h>
#include <linux/slab.h>
#include <linux/spinlock.h>

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,1,0)
/**
 * rhashtable_walk_init - Initialise an iterator
 * @ht:		Table to walk over
 * @iter:	Hash table Iterator
 * @gfp:	GFP flags for allocations
 *
 * This function prepares a hash table walk.
 *
 * Note that if you restart a walk after rhashtable_walk_stop you
 * may see the same object twice.  Also, you may miss objects if
 * there are removals in between rhashtable_walk_stop and the next
 * call to rhashtable_walk_start.
 *
 * For a completely stable walk you should construct your own data
 * structure outside the hash table.
 *
 * This function may sleep so you must not call it from interrupt
 * context or with spin locks held.
 *
 * You must call rhashtable_walk_exit if this function returns
 * successfully.
 */
int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter,
			 gfp_t gfp)
{
	iter->ht = ht;
	iter->p = NULL;
	iter->slot = 0;
	iter->skip = 0;

	iter->walker = kmalloc(sizeof(*iter->walker), gfp);
	if (!iter->walker)
		return -ENOMEM;

	spin_lock(&ht->lock);
	iter->walker->tbl =
		rcu_dereference_protected(ht->tbl, lockdep_is_held(&ht->lock));
	list_add(&iter->walker->list, &iter->walker->tbl->walkers);
	spin_unlock(&ht->lock);

	return 0;
}
EXPORT_SYMBOL_GPL(rhashtable_walk_init);
#endif /* >= 4.1 */
