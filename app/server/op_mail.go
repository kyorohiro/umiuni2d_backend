package hello

import (
	"github.com/mailgun/mailgun-go"
	"golang.org/x/net/context"
	"google.golang.org/appengine/urlfetch"
)

func SendMail(ctx context.Context, subject string, body string, toAddrs []string) error {
	httpc := urlfetch.Client(ctx)

	mg := mailgun.NewMailgun(
		ConfigMailgunDomain,    // Domain name
		ConfigMailgunApiKey,    // API Key
		ConfigMailgunPublicKey, // Public Key
	)
	mg.SetClient(httpc)

	message := mg.NewMessage(
		/* From */ "Excited User <mailgun@"+ConfigMailgunDomain+">",
		/* Subject */ subject,
		/* Body */ body)
	for _, v := range toAddrs {
		message.AddRecipient(v)
	}
	_, _, err := mg.Send(message)
	return err
}
