#ifndef __BACKPORT_LINUX_RHASHTABLE_H
#define __BACKPORT_LINUX_RHASHTABLE_H
#include_next <linux/rhashtable.h>
#include <linux/version.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(4,7,0)
#define rhashtable_walk_init LINUX_BACKPORT(rhashtable_walk_init)
int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter,
			 gfp_t gfp);
#endif /* < 3.10 */

#endif /* __BACKPORT_LINUX_RHASHTABLE_H */
