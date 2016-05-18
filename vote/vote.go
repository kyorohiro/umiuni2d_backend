package gaevote

import (
	"fmt"
	//	"math/rand"
	"errors"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	//	"google.golang.org/appengine/memcache"
	//	"google.golang.org/appengine/log"
)

type GaeVoteItem struct {
	VoteName    string
	TicketId    string
	Description string
	Target      string
}

type VoteManager struct {
	VoteName string
	Counters map[string]*Counter
	//VoteId   string
}

const (
	GaeVoteItemKind = "GaeVoteItem"
)

var ErrorNotFound = errors.New("not found")
var ErrorAlreadyFound = errors.New("already found")

func NewVoteManager(voteName string, targets []string) *VoteManager {
	ret := new(VoteManager)
	ret.VoteName = voteName
	ret.Counters = make(map[string]*Counter)
	for _, v := range targets {
		ret.Counters[v] = NewCounter(10, voteName+"_"+v)
	}
	return ret
}

func (obj *VoteManager) GetGaeVoteItemObjFromTicketID(ctx context.Context, ticketId string) (*GaeVoteItem, *datastore.Key, error) {
	key := datastore.NewKey(ctx, GaeVoteItemKind, obj.MakeKeyNameFromTicketId(ticketId), 0, nil)
	var item GaeVoteItem
	err := datastore.Get(ctx, key, &item)
	return &item, key, err
}

func (obj *VoteManager) MakeKeyNameFromTicketId(ticketId string) string {
	return fmt.Sprintf("%s_%s", obj.VoteName, ticketId)
}

func (obj *VoteManager) Vote(ctx context.Context, ticketId string, description string, target string) error {
	if _, ok := obj.Counters[target]; ok == false {
		return ErrorNotFound
	}
	counter := obj.Counters[target]

	e3 := counter.Add(ctx, 1, func(ctx context.Context) error {
		a, key, e1 := obj.GetGaeVoteItemObjFromTicketID(ctx, ticketId)
		if e1 == nil || a.Target != "" {
			return ErrorAlreadyFound
		}
		a.VoteName = obj.VoteName
		a.TicketId = ticketId
		a.Description = description
		a.Target = target
		_, e2 := datastore.Put(ctx, key, a)
		return e2
	}, &datastore.TransactionOptions{XG: true})
	return e3
}
