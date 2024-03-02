package main

import "core:testing"

Sparse_Array_Item :: struct($T: typeid) {
	item: T,
	free: bool,
	next: Maybe(int),
}

Sparse_Array :: struct($T: typeid) {
	items: #soa[dynamic]Sparse_Array_Item(T),
	head:  Maybe(int),
}

sparse_array_append :: proc(list: ^Sparse_Array($T), item: T) -> int {
	if head, ok := list.head.?; ok {
		list.head = list.items[head].next

		list.items[head].item = item
        list.items[head].free = false
        list.items[head].next = nil

        return head
	} 

	append_soa(&list.items, Sparse_Array_Item(T){item = item})
	return len(list.items) - 1
}

sparse_array_remove :: proc(list: ^Sparse_Array($T), index: int) {
    if index >= len(list.items) do return
    if list.items[index].free do return 

    list.items[index].free = true
    list.items[index].next = list.head
    list.head = index
}

sparse_array_get :: proc(arr: ^Sparse_Array($T), index: int) -> Maybe(^T) {
    if index >= len(arr.items) do return nil
    if arr.items[index].free do return nil

    return &arr.items[index].item
}

@(test)
sparse_array_append_test :: proc(t: ^testing.T) {
	sparse_array: Sparse_Array(int)

	index := sparse_array_append(&sparse_array, 69)
	testing.expect_value(t, index, 0)
	testing.expect_value(t, sparse_array_get(&sparse_array, index).?^, 69)

    sparse_array_remove(&sparse_array, 0)
	testing.expect_value(t, sparse_array.head, 0)

	index = sparse_array_append(&sparse_array, 420)
	testing.expect_value(t, index, 0)
	testing.expect_value(t, sparse_array_get(&sparse_array, index).?^, 420)
	testing.expect_value(t, sparse_array.head, nil)

	index = sparse_array_append(&sparse_array, 69)
	testing.expect_value(t, index, 1)
	testing.expect_value(t, sparse_array_get(&sparse_array, index).?^, 69)

    sparse_array_remove(&sparse_array, 0)
	testing.expect_value(t, sparse_array.head, 0)

    sparse_array_remove(&sparse_array, 1)
	testing.expect_value(t, sparse_array.head, 1)
	testing.expect_value(t, sparse_array.items[1].next, 0)
	testing.expect_value(t, sparse_array.items[0].next, nil)

	testing.expect_value(t, sparse_array_get(&sparse_array, 69), nil)
}
