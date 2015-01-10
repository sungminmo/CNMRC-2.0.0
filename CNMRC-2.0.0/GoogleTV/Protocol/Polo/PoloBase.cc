/*
Ê* Copyright 2012 Google Inc. All Rights Reserved.
Ê*
Ê* Licensed under the Apache License, Version 2.0 (the "License");
Ê* you may not use this file except in compliance with the License.
Ê* You may obtain a copy of the License at
Ê*
Ê* Ê Ê Êhttp://www.apache.org/licenses/LICENSE-2.0
Ê*
Ê* Unless required by applicable law or agreed to in writing, software
Ê* distributed under the License is distributed on an "AS IS" BASIS,
Ê* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
Ê* See the License for the specific language governing permissions and
Ê* limitations under the License.
Ê*/

#include "PoloBase.h"


__strong PoloType PoloSetupInstance(PoloType instance,
                                    size_t instanceSize,
                                    struct PoloClass *cls) {
  struct PoloBase *obj = (struct PoloBase *)instance;
  obj->instanceSize = instanceSize;
  obj->cls = cls;
  if (cls)
    obj->isa = cls->instanceIsa;

  if (cls->init)
    return cls->init(obj);
  else
    return obj;
}

__strong PoloType PoloAlloc(PoloMemoryAllocatorRef allocator,
                            size_t extraBytes,
                            struct PoloClass *cls) {
  struct PoloBase *obj;
  size_t instanceSize = cls->instanceSize;

  if (instanceSize < sizeof(struct PoloBase))
    instanceSize = sizeof(struct PoloBase);

  instanceSize += extraBytes;

  if (!allocator)
    allocator = PoloMemoryAllocatorGetDefault();

  obj = (struct PoloBase *) PoloMemoryAllocatorAlloc(allocator, instanceSize);
  return PoloSetupInstance(obj, instanceSize, cls);
}

__strong PoloType PoloCopyObj(PoloType obj) {
  struct PoloBase *instance = (struct PoloBase *)obj;

  if (instance->cls->copy) {
    return instance->cls->copy(instance);
  } else {
    return PoloMemoryAllocatorCopy(PoloMemoryAllocatorGetAllocatorForPtr(obj),
                                   obj,
                                   instance->instanceSize);
  }
}

#pragma mark Polo Default Allocator

#include <ext/hash_map>

using namespace std;
#ifdef __GNUC__
using namespace __gnu_cxx;
#endif

static hash_map<uintptr_t, uint32_t> poloReferencesMap;
static PoloSpinLock poloReferencesMapLock;
static hash_map<uintptr_t, PoloMemoryAllocatorRef> poloObjectsAllocatorsMap;
static PoloSpinLock poloObjectsAllocatorsMapLock;

static void PoloBaseInit(void) __attribute__((constructor));
static void PoloBaseInit(void) {
  PoloSpinLockInit(&poloReferencesMapLock);
  PoloSpinLockInit(&poloObjectsAllocatorsMapLock);
}

void *PoloDefaultAllocatorAlloc(size_t length, void *info) {
  return calloc(1, length);
}

void *PoloDefaultAllocatorCopy(void *fromPtr, size_t length, void *info) {
  void *ret = malloc(length);
  memcpy(ret, fromPtr, length);
  return ret;
}

void PoloDefaultAllocatorFree(void *ptr, void *info) {
  free(ptr);
}

void *PoloDefaultAllocatorStrongAssign(void *ptr, void *info) {
  PoloSpinLockLock(&poloReferencesMapLock);
  ++poloReferencesMap[(uint64_t)ptr];
  PoloSpinLockUnlock(&poloReferencesMapLock);
  return ptr;
}

void *PoloDefaultAllocatorWeakAssign(void *ptr, void *info) {
  return ptr;
}

uint32_t PoloDefaultAllocatorStrongResign(void *ptr, void *info) {
  uint32_t count;
  PoloSpinLockLock(&poloReferencesMapLock);
  hash_map<uintptr_t, uint32_t>::const_iterator entryIt;
  entryIt = poloReferencesMap.find((uintptr_t)ptr);
  if (entryIt != poloReferencesMap.end()) {
    count = entryIt->second - 1;
    if (count == 0)
      poloReferencesMap.erase((uintptr_t)ptr);
    else
      poloReferencesMap[(uintptr_t)ptr] = count;
    // Normalize count, since 0 actually means one reference
    ++count;
  } else {
    count = 0;
  }
  PoloSpinLockUnlock(&poloReferencesMapLock);
  return count;
}

uint32_t PoloDefaultAllocatorWeakResign(void *ptr, void *info) {
  return 1;
}

uint32_t PoloDefaultAllocatorGetRefCount(void *ptr, void *info) {
  uint32_t count;
  PoloSpinLockLock(&poloReferencesMapLock);
  hash_map<uintptr_t, uint32_t>::const_iterator entryIt;
  entryIt = poloReferencesMap.find((uintptr_t)ptr);
  if (entryIt != poloReferencesMap.end())
    count = entryIt->second + 1;
  else
    count = 1;
  PoloSpinLockUnlock(&poloReferencesMapLock);
  return count;
}

struct polo_memory_allocator polo_builtin_allocator = {
  NULL,
  PoloDefaultAllocatorAlloc,
  PoloDefaultAllocatorCopy,
  PoloDefaultAllocatorFree,
  PoloDefaultAllocatorStrongAssign,
  PoloDefaultAllocatorWeakAssign,
  PoloDefaultAllocatorStrongResign,
  PoloDefaultAllocatorWeakResign,
  PoloDefaultAllocatorGetRefCount
};
const PoloMemoryAllocatorRef PoloBuiltinAllocator = &polo_builtin_allocator;
static PoloMemoryAllocatorRef poloDefaultAllocator = PoloBuiltinAllocator;

PoloMemoryAllocatorRef PoloMemoryAllocatorGetDefault(void) {
  return poloDefaultAllocator;
}

void PoloMemoryAllocatorSetDefault(PoloMemoryAllocatorRef allocator) {
  if (allocator != NULL)
    poloDefaultAllocator = allocator;
}

#pragma mark Polo Allocator API

void *PoloMemoryAllocatorAlloc(PoloMemoryAllocatorRef allocator,
                               size_t length) {
  void *ptr = allocator->alloc(length, allocator->info);
  if (ptr) {
    PoloSpinLockLock(&poloObjectsAllocatorsMapLock);
    poloObjectsAllocatorsMap[(uintptr_t)ptr] = allocator;
    PoloSpinLockUnlock(&poloObjectsAllocatorsMapLock);
  }
  return ptr;
}

void *PoloMemoryAllocatorAssign(void *ptr,
                                int operation) {
  PoloMemoryAllocatorRef allocator = PoloMemoryAllocatorGetAllocatorForPtr(ptr);
  if (ptr) {
    void *info = allocator->info;
    ptr = operation == POLO_MEM_OP_STRONG ? allocator->strongAssign(ptr, info)
                                          : allocator->weakAssign(ptr, info);
  }
  return ptr;
}

void PoloMemoryAllocatorResign(void *ptr,
                               int operation) {
  if (ptr) {
    PoloMemoryAllocatorRef allocator;
    allocator = PoloMemoryAllocatorGetAllocatorForPtr(ptr);
    void *info = allocator->info;
    uint32_t count = POLO_MEM_OP_STRONG ? allocator->strongResign(ptr, info)
                                        : allocator->weakResign(ptr, info);
    if (!count) {
      PoloSpinLockLock(&poloObjectsAllocatorsMapLock);
      poloObjectsAllocatorsMap.erase((uintptr_t)ptr);
      PoloSpinLockUnlock(&poloObjectsAllocatorsMapLock);
      allocator->free(ptr, info);
    }
  }
}

void PoloRelease(PoloType ptr) {
  if (ptr) {
    PoloMemoryAllocatorRef allocator;
    allocator = PoloMemoryAllocatorGetAllocatorForPtr(ptr);
    uint32_t count = allocator->strongResign(ptr, allocator->info);
    if (!count) {
      struct PoloBase *obj = (struct PoloBase *)ptr;
      if (obj->cls->destroy)
        obj->cls->destroy(ptr);
      PoloSpinLockLock(&poloObjectsAllocatorsMapLock);
      poloObjectsAllocatorsMap.erase((uintptr_t)ptr);
      PoloSpinLockUnlock(&poloObjectsAllocatorsMapLock);
      allocator->free(ptr, allocator->info);
    }
  }
}

uint32_t PoloMemoryAllocatorGetRefCount(void *ptr) {
  if (ptr) {
    PoloMemoryAllocatorRef allocator;
    allocator = PoloMemoryAllocatorGetAllocatorForPtr(ptr);
    return allocator->getRefCount(ptr, allocator->info);
  } else {
    return 0;
  }
}

PoloMemoryAllocatorRef PoloMemoryAllocatorGetAllocatorForPtr(void *ptr) {
  PoloMemoryAllocatorRef allocator = NULL;
  PoloSpinLockLock(&poloObjectsAllocatorsMapLock);
  hash_map<uintptr_t, PoloMemoryAllocatorRef>::const_iterator entryIterator;
  entryIterator = poloObjectsAllocatorsMap.find((uintptr_t)ptr);
  if (entryIterator != poloObjectsAllocatorsMap.end())
    allocator = entryIterator->second;
  PoloSpinLockUnlock(&poloObjectsAllocatorsMapLock);
  return allocator;
}

void *PoloMemoryAllocatorCopy(PoloMemoryAllocatorRef allocator,
                              void *fromPtr,
                              size_t length) {
  void *ptr = allocator->copy(fromPtr, length, allocator->info);
  if (ptr) {
    PoloSpinLockLock(&poloObjectsAllocatorsMapLock);
    poloObjectsAllocatorsMap[(uintptr_t)ptr] = allocator;
    PoloSpinLockUnlock(&poloObjectsAllocatorsMapLock);
  }
  return ptr;
}
