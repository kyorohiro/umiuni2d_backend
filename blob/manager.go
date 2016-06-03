package blob

import (
	"strings"

	"net/url"

	"golang.org/x/net/context"
	//	"google.golang.org/appengine"

	"bytes"
	"net/http"

	"errors"

	"mime/multipart"

	"google.golang.org/appengine/blobstore"
	"google.golang.org/appengine/datastore"
	"google.golang.org/appengine/urlfetch"
)

type BlobManager struct {
	BasePath     string
	blobItemKind string
}

type GaeObjectBlobItem struct {
	Parent  string
	Name    string
	BlobKey string
}

type BlobItem struct {
	gaeObject    *GaeObjectBlobItem
	gaeObjectKey *datastore.Key
}

func NewBlobManager(uploadUrlBase string, blobItemKind string) *BlobManager {
	ret := new(BlobManager)
	ret.blobItemKind = blobItemKind
	ret.BasePath = uploadUrlBase
	return ret
}

func (obj *BlobManager) NewBlobItem(ctx context.Context, parent string, name string, blobKey string) *BlobItem {
	ret := new(BlobItem)
	ret.gaeObject = new(GaeObjectBlobItem)
	ret.gaeObject.Parent = parent
	ret.gaeObject.Name = name
	ret.gaeObject.BlobKey = blobKey
	ret.gaeObjectKey = datastore.NewKey(ctx, obj.blobItemKind, ""+parent+"/"+name, 0, nil)
	return ret
}

func (obj *BlobItem) SaveDB(ctx context.Context) error {
	_, e := datastore.Put(ctx, obj.gaeObjectKey, obj.gaeObject)
	return e
}

func (obj *BlobItem) GetParent() string {
	return obj.gaeObject.Parent
}

func (obj *BlobItem) GetName() string {
	return obj.gaeObject.Name
}

func (obj *BlobItem) GetBlobKey() string {
	return obj.gaeObject.BlobKey
}

// filepath "/gs/bucket_name/object_name"
// basepath "/api/v1/on_uploaded"
func (obj *BlobManager) MakeRequestUrl(ctx context.Context, dirName string, fileName string, opt string) (string, error) {
	if opt == "" {
		opt = "none"
	}

	option := blobstore.UploadURLOptions{
		//MaxUploadBytes: 1024 * 1024 * 1024,
		StorageBucket: dirName,
	}
	var ary = []string{obj.BasePath + "?dir=", url.QueryEscape(dirName), "&file=", url.QueryEscape(fileName), "&opt=", opt}
	uu, err2 := blobstore.UploadURL(ctx, strings.Join(ary, ""), &option)
	return uu.String(), err2
}

func (obj *BlobManager) HandleUploaded(ctx context.Context, r *http.Request) (*BlobItem, string, error) {
	blobs, _, err := blobstore.ParseUpload(r)
	if err != nil {
		// error
		return nil, "", errors.New("")
	}
	dirName := r.FormValue("dir")
	fileName := r.FormValue("file")
	reqId := string(r.FormValue("opt"))

	file := blobs["file"]
	if len(file) == 0 {
		// error
		return nil, "", errors.New("")
	}
	blobKey := string(file[0].BlobKey)
	blobItem := obj.NewBlobItem(ctx, dirName, fileName, blobKey)
	err = blobItem.SaveDB(ctx)
	return blobItem, reqId, err
}

func (obj *BlobManager) SaveData(c context.Context, url string, sampleData []byte) error {

	// Now you can prepare a form that you will submit to that URL.
	var b bytes.Buffer
	fw := multipart.NewWriter(&b)
	// Do not change the form field, it must be "file"!
	// You are free to change the filename though, it will be stored in the BlobInfo.
	file, err := fw.CreateFormFile("file", "example.csv")
	if err != nil {
		return err
	}
	if _, err = file.Write(sampleData); err != nil {
		return err
	}
	// Don't forget to close the multipart writer.
	// If you don't close it, your request will be missing the terminating boundary.
	fw.Close()

	// Now that you have a form, you can submit it to your handler.
	req, err := http.NewRequest("POST", url, &b)
	if err != nil {
		return err
	}
	// Don't forget to set the content type, this will contain the boundary.
	req.Header.Set("Content-Type", fw.FormDataContentType())

	// Now submit the request.
	client := urlfetch.Client(c)
	res, err := client.Do(req)
	if err != nil {
		return err
	}

	// Check the response status, it should be whatever you return in the `/upload` handler.
	if res.StatusCode != http.StatusCreated {
		return err
	}
	// Everything went fine.
	return nil
}
