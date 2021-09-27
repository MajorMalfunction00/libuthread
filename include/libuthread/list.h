#ifndef LIBUTHREAD_LIST_H
#define LIBUTHREAD_LIST_H

#include <libuthread/defines.h>
/* circular doubly linked list */

struct list_link {
	struct list_link *next;
	struct list_link *prev;
};

#define list_entry(ptr, type, member) \
	containerof(ptr, type, member)

#define list_next_entry(pos, type, member) \
	list_entry((pos)->member.next, type, member)

#define list_prev_entry(pos, type, member) \
	list_entry((pos)->member.prev, type, member)

/*
 * list_foreach_next - forward iteration over a list
 * @pos: iterator variable, of type 'struct list_link *'
 * @head: pointer to the head of the list
 */
 
#define list_foreach_next(pos, head) \
	for(pos = (head)->next; pos != head; pos = (pos)->next)

/*
 * list_foreach_prev - backward iteration over a list
 * @pos: iterator variable, of type 'struct list_link *'
 * @head: pointer to the head of the list
 */
 	
#define list_foreach_prev(pos, head) \
	for(pos = (head)->prev; pos != head; pos = (pos)->prev)

/*
 * list_foreach_entry_next - iteration over a list of a given type
 * @pos: cursor of type 'type *'
 * @head: head of the list
 * @type: type of list to iterate over
 * @member: name of the 'struct list' member embedded in 'type'
 */
 
#define list_foreach_entry_next(pos, head, type, member) \
	for(pos = list_entry((head)->next, type, member);	 	\
		&(pos)->member != head; 						\
		pos = list_next_entry(pos, type, member))

/*
 * list_foreach_entry_prev(pos, head, type, member) \
 * @pos: cursor of type 'type *'
 * @head: head of the list
 * @type: type of list to iterate over
 * @member: name of the 'struct list' member embedded in 'type'
 */
 
#define list_foreach_entry_prev(pos, head, type, member) \
	for(pos = list_entry((head)->prev, type, member); \
		&(pos)->member != head; 						\
		pos = list_prev_entry(pos, type, member))

#define list_foreach_entry_next_safe(pos, next, head, type, member) \
    for (pos = list_entry((head)->next, type, member), \
                next = list_next_entry(pos, type, member); \
            &pos->member != (head); \
            pos = next, next = list_next_entry(pos, type, member))
        
#define list_foreach_continue(pos, head) \
	for (pos = pos->next; pos != (head); pos = pos->next)
    
#define list_foreach_entry_next_continue(pos, head, type, member) \
	for(pos = list_next_entry(pos, type, member);	 	\
		&(pos)->member != head; 						\
		pos = list_next_entry(pos, type, member))


static inline void list_init(struct list_link *node)
{
	node->next = node;
	node->prev = node;
}

static inline int list_is_empty(struct list_link *list)
{
    return (list->next == list);
}

static inline void __list_add(struct list_link *new,
			      struct list_link *prev,
			      struct list_link *next)
{
	next->prev = new;
	new->next = next;
	new->prev = prev;
	prev->next = new;
}

static inline void list_add_tail(struct list_link *new, struct list_link *head)
{
	__list_add(new, head->prev, head);
}

static inline void __list_merge(struct list_link *list, struct list_link *prev, struct list_link *next)
{
        struct list_link *first = list->next;
        struct list_link *last = list->prev;
        
        first->prev = prev;
        prev->next = first;
        
        last->next = next;
        next->prev = last;
}

static inline void __list_del(struct list_link *prev, struct list_link *next)
{
	next->prev = prev;
    prev->next = next;
}

static inline void list_del(struct list_link *entry)
{
    __list_del(entry->prev, entry->next);
    list_init(entry);
}

#endif /* EOF */
