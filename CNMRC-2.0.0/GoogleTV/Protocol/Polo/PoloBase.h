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

/*
 *  This file implements a primitive runtime designed specifically for this
 *  library's needs. It is designed to allow easy integration with ObjC and to
 *  provide toll-free bridging for Polo objects.
 *  Changes to the runtime may be introduced in the future in order to allow
 *  easier integration with various other languages. Therefore, everything
 *  defined here should be considered private.
 */

#ifndef HEADER_POLO_BASE_H
#define HEADER_POLO_BASE_H

#include <sys/types.h>
#include <stdint.h>

#ifdef  __cplusplus
extern "C" {
#endif

#if !defined(__OBJC__)

#ifndef __strong
#define __strong
#endif

#ifndef __weak
#define __weak
#endif

#endif

#include <stdlib.h>
#include <string.h>

typedef void *PoloType;

// The entire polo library allocates memory using the default memory allocator.
// The default allocator provides reference counting, and is designed to be
// as generic as possible. If your environment has different requirements, you
// can provide your own allocator.
struct polo_memory_allocator {
  // Reserved for the allocator's use. Set it to whatever your allocator needs
  // and it'll be passed to each function.
  void *info;
  // Allocates and returns a new memory block of size |length| bytes.
  void *(*alloc)(size_t length, void *info);
  // Allocates a new memory block of size |length| and copies |length| bytes
  // to it from |fromPtr|. Returns the newly allocated block.
  void *(*copy)(void *fromPtr, size_t length, void *info);
  // Frees the memory block |ptr|.
  void (*free)(void *ptr, void *info);
  // Creates a strong assignment to |ptr| and returns |ptr| or any other pointer
  // as fits the environment. The default allocator increments the reference
  // count of |ptr| by one and returns |ptr|.
  void *(*strongAssign)(void *ptr, void *info);
  // Creates a weak reference to |ptr| and returns |ptr| or any other pointer
  // as fits the environment. The default allocator simply returns |ptr| without
  // incrementing its reference count.
  void *(*weakAssign)(void *ptr, void *info);
  // Undos one strong assign to |ptr| and returns the reference count of |ptr|.
  // If the result of this function is greater than 0, |ptr| will be kept alive.
  // If the result is 0, |ptr| will be freed by the free function of the
  // allocator.
  uint32_t (*strongResign)(void *ptr, void *info);
  // Does the same thing as |strongResign|, except undos a weak reference. The
  // result of this function has the same effect as the result of
  // |strongResign|.
  uint32_t (*weakResign)(void *ptr, void *info);
  // Returns the reference count of |ptr|. The result of this function is
  // implementation-dependent and should not be relied upon.
  uint32_t (*getRefCount)(void *ptr, void *info);
};
typedef struct polo_memory_allocator *PoloMemoryAllocatorRef;

#define POLO_MEM_OP_STRONG  1
#define POLO_MEM_OP_WEAK    0

// Allocates and returns a memory block of size |length| bytes. Returns NULL
// if an error had occured.
extern void *PoloMemoryAllocatorAlloc(PoloMemoryAllocatorRef allocator,
                                      size_t length);
// Creates an assignment to |ptr|. Pass POLO_MEM_OP_STRONG or POLO_MEM_OP_WEAK
// as the value of |operation| for either a strong or weak assignment
// respectively.
// Returns |ptr|.
extern void *PoloMemoryAllocatorAssign(void *ptr,
                                       int operation);
// Creates a strong assignment to |ptr| and returns it.
#define PoloMemoryAllocatorStrongAssign(ptr) \
PoloMemoryAllocatorAssign((void *)(ptr), POLO_MEM_OP_STRONG)
// Creates a weak assignemtn to |ptr| and returns it.
#define PoloMemoryAllocatorWeakAssign(ptr) \
PoloMemoryAllocatorAssign((void *)(ptr), POLO_MEM_OP_WEAK)
// Undos a single assignment to |ptr|. Pass POLO_MEM_OP_STRONG or
// POLO_MEM_OP_WEAK as the value of |operation| for either a strong or weak
// assignment respectively.
extern void PoloMemoryAllocatorResign(void *ptr,
                                      int operation);
// Undos a single strong assignment to |ptr|.
#define PoloMemoryAllocatorStrongResign(ptr) \
PoloMemoryAllocatorResign((void *)(ptr), POLO_MEM_OP_STRONG)
// Undos a single weak assignment to |ptr|.
#define PoloMemoryAllocatorWeakResign(ptr) \
PoloMemoryAllocatorResign((void *)(ptr), POLO_MEM_OP_WEAK)
// Returns the reference count of |ptr|. This value is implementation dependent
// and should not be relied upon.
extern uint32_t PoloMemoryAllocatorGetRefCount(void *ptr);
// Returns the allocator that was used to allocate |ptr|. If |ptr| was allocated
// not in the context of a PoloMemoryAllocator, this function will return NULL.
extern PoloMemoryAllocatorRef PoloMemoryAllocatorGetAllocatorForPtr(void *ptr);
// Copies |length| bytes from |ptr| to a freshly allocated memory (of size
// |length| bytes) that was allocated using |allocator|. Returns the newly
// allocated memory.
extern void *PoloMemoryAllocatorCopy(PoloMemoryAllocatorRef allocator,
                                     void *ptr,
                                     size_t length);

extern PoloMemoryAllocatorRef PoloMemoryAllocatorGetDefault(void);
extern void PoloMemoryAllocatorSetDefault(PoloMemoryAllocatorRef allocator);

extern const PoloMemoryAllocatorRef PoloBuiltinAllocator;

// A primitive class definition for Polo objects
struct PoloClass {
  // When interfacing with ObjC objects, a Polo class may act as an object by
  // itself. Not sure how useful it'd be.
  void *isa;
  // The |isa| member of all future instances of this class will be set to the
  // value of this property.
  void *instanceIsa;
  // The default size of each instance of the class. May be different for actual
  // instances.
  size_t instanceSize;
  // An optional init function
  PoloType (*init)(PoloType ptr);
  // An optional destroy function that's responsible for any cleanups of the
  // given instance. If you're using GC you must make sure this function is
  // called before the object is freed.
  void (*destroy)(PoloType ptr);
  // Invoked upon copy of the object. If NULL then the runtime uses memcpy() to
  // blindly copy the memory block.
  // |fromObj| is the object that should be copied. You're responsible of
  // returning a fresh object that's a copy of |fromObject|.
  PoloType (*copy)(PoloType fromObj);
};

// Each Polo object must start with this struct
struct PoloBase {
  // Reserved for future ObjC bridge
  __strong void *isa;
  __strong struct PoloClass *cls;
  // The actual size of the instance. May be larger than class->instanceSize.
  size_t instanceSize;
};

extern __strong PoloType PoloAlloc(PoloMemoryAllocatorRef allocator,
                                   size_t extraBytes,
                                   struct PoloClass *cls);
// Does nothing for NULL
static inline __strong PoloType PoloRetain(PoloType obj) {
  return PoloMemoryAllocatorStrongAssign(obj);
}
// Does nothing if NULL is passed
extern void PoloRelease(PoloType obj);
extern __strong PoloType PoloCopyObj(PoloType obj);

#if __APPLE__
#include <libkern/OSAtomic.h>
#define PoloSpinLock OSSpinLock
#define PoloSpinLockInit(lockPtr) do { *(lockPtr) = OS_SPINLOCK_INIT; } while(0)
#define PoloSpinLockDestroy(lockPtr)
#define PoloSpinLockLock(lockPtr) OSSpinLockLock(lockPtr)
#define PoloSpinLockUnlock(lockPtr) OSSpinLockUnlock(lockPtr)
#define PoloSpinLockTryLock(lockPtr) OSSpinLockTry(lockPtr)
#else
#warning No spinlock implementation available for this platfrom. Using pthread mutex instead.
#include <pthread.h>
#define PoloSpinLock pthread_mutex_t
#define PoloSpinLockInit(lockPtr) pthread_mutex_init(lockPtr, NULL)
#define PoloSpinLockDestroy(lockPtr) pthread_mutex_destroy(lockPtr)
#define PoloSpinLockLock(lockPtr) pthread_mutex_lock(lockPtr)
#define PoloSpinLockUnlock(lockPtr) pthread_mutex_unlock(lockPtr)
#define PoloSpinLockTryLock(lockPtr) pthread_mutex_trylock(lockPtr)
#endif

#ifdef  __cplusplus
}
#endif
#endif
