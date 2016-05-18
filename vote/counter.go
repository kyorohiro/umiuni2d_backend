package gaevote

import (
	"fmt"
	"math/rand"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	"google.golang.org/appengine/log"
	"google.golang.org/appengine/memcache"
)

type GaeVoteCounterItem struct {
	CounterName string
	Count       int64
}

const (
	GaeVoteCounterItemKind = "GaeVoteCounterItem"
)

type Counter struct {
	NumOfShardingCounter int
	Name                 string
	CounterID            string
}

func NewCounter(maxOfSharding int, name string) *Counter {
	ret := new(Counter)
	ret.NumOfShardingCounter = maxOfSharding
	ret.Name = name
	ret.CounterID = fmt.Sprintf("%s:%s", GaeVoteCounterItemKind, name)
	return ret
}

func (obj *Counter) CountAtKey(ctx context.Context) (int64, error) {
	var total int64 = 0

	if _, err := memcache.JSON.Get(ctx, obj.CounterID, &total); err == nil {
		return total, nil
	}

	var item GaeVoteCounterItem
	for i := 0; i < obj.NumOfShardingCounter; i++ {
		k := datastore.NewKey(ctx, GaeVoteCounterItemKind, obj.MakeKeyNameWithID(i), 0, nil)
		e := datastore.Get(ctx, k, &item)
		if e != nil {
			continue
		}
		total += item.Count
	}

	memcache.JSON.Set(ctx, &memcache.Item{
		Key:        obj.CounterID,
		Object:     &total,
		Expiration: 60,
	})
	return total, nil
}

func (obj *Counter) Count(ctx context.Context) (int64, error) {
	var total int64 = 0
	if _, err := memcache.JSON.Get(ctx, obj.CounterID, &total); err == nil {
		return total, nil
	}
	query := datastore.NewQuery(GaeVoteCounterItemKind)
	if obj.Name != "" {
		query = query.Filter("CounterName =", obj.Name)
	}

	for t := query.Run(ctx); ; {
		var s GaeVoteCounterItem
		_, err := t.Next(&s)
		if err == datastore.Done {
			break
		}
		if err != nil {
			return 0, nil
		}
		total += s.Count
	}

	memcache.JSON.Set(ctx, &memcache.Item{
		Key:        obj.CounterID,
		Object:     &total,
		Expiration: 60,
	})
	return total, nil
}

func (obj *Counter) MakeKeyName() string {
	return fmt.Sprintf("%s_%d", obj.CounterID, rand.Intn(obj.NumOfShardingCounter))
}

func (obj *Counter) MakeKeyNameWithID(keyid int) string {
	return fmt.Sprintf("%s_%d", obj.CounterID, keyid)
}

func (obj *Counter) Increment(ctx context.Context) error {
	return obj.Add(ctx, +1, nil, nil)
}

func (obj *Counter) Decrement(ctx context.Context) error {
	return obj.Add(ctx, -1, nil, nil)
}

func debugPrint(ctx context.Context, t string) {
	log.Infof(ctx, t)
}

func (obj *Counter) Add(ctx context.Context, v int64, optFunc func(tc context.Context) error, options *datastore.TransactionOptions) error {
	keyName := obj.MakeKeyName()

	err := datastore.RunInTransaction(ctx, func(ctx context.Context) error {
		keyCounter := datastore.NewKey(ctx, GaeVoteCounterItemKind, keyName, 0, nil)

		if optFunc != nil {
			err := optFunc(ctx)
			if err != nil {
				return datastore.ErrConcurrentTransaction
			}
		}
		var counter GaeVoteCounterItem
		err := datastore.Get(ctx, keyCounter, &counter)
		if err != nil && err != datastore.ErrNoSuchEntity {
			return datastore.ErrConcurrentTransaction
		}
		counter.CounterName = obj.Name
		counter.Count += v
		_, err = datastore.Put(ctx, keyCounter, &counter)
		if err != nil {
			return datastore.ErrConcurrentTransaction
		}
		return nil
	}, options)
	//
	if err != nil {
		return err
	}
	//
	memcache.IncrementExisting(ctx, obj.CounterID, v)
	return nil
}
