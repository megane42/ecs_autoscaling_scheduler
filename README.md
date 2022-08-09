# EcsAutoscalingScheduler

![screen](https://user-images.githubusercontent.com/8451003/183574722-93d2c31d-c5af-4fb0-a1a1-9099088c72b8.gif)

## Requirements

- Do `aws configure`
  - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
- Register your ECS service as a scalable target
  - https://docs.aws.amazon.com/cli/latest/reference/application-autoscaling/register-scalable-target.html

## Installation

```ruby
gem 'ecs_autoscaling_scheduler'
```

## Usage

```
AWS_PROFILE=foo ecs_autoscaling_scheduler
```

## Motivations

- At this time, we can configure "target-tracking scaling" or "step scaling" for your ECS service through the AWS Management Console or copilot-cli, but somehow can not configure "scheduled scaling" (even though they have APIs to set up scheduled scaling).
- Target-tracking scaling or step scaling is not enough for a spike access.

## Development

- Check current behavior from console
  - `bin/console`
- Check current behavior as entire gem
  - `bin/run`
- Release
  - `emacs CHANGELOG.md` (see https://keepachangelog.com/en/1.0.0/)
  - `emacs lib/ecs_autoscaling_scheduler/version.rb`
  - `bundle exec rake release`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/megane42/ecs_autoscaling_scheduler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
