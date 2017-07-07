# Bot-pocalypse Script

This is the code for a silly video I did for a talk by Elizabeth Lawler gave at the Cyberark Impact 2017 conference. This code isn't all that pretty, but does offer an example of how one strings together a Slack Bot in Ruby. It includes a "listener bot" (`deployer.rb`), a job queue to introduce delay in responses, and a conversation between two bots and the deployer (`supervisor.rb`).

This is a great example of how easy it is to stitch together bots in Slack, and how you can even make them talk to each other!

## To Run

Clone and step into the directory. You'll need to run this in three separate tabs:

The `deployer` bot to respond to requests:

```bash
$ ruby deployer.rb
```

The job queue:

```bash
$ sidekiq -r ./jobs.rb
```

The script to execute the conversation (hit return to send each message):

```bash
$ ruby supervisor.rb
```
