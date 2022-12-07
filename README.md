# GraphQL::KaminariConnection

[![Gem](https://img.shields.io/gem/v/graphql-kaminari_connection.svg)](https://rubygems.org/gems/graphql-kaminari_connection)
[![Build Status](https://travis-ci.org/increments/graphql-kaminari_connection.svg?branch=master)](https://travis-ci.org/increments/graphql-kaminari_connection)
[![Code Climate](https://codeclimate.com/github/increments/graphql-kaminari_connection/badges/gpa.svg)](https://codeclimate.com/github/increments/graphql-kaminari_connection)
[![Test Coverage](https://codeclimate.com/github/increments/graphql-kaminari_connection/badges/coverage.svg)](https://codeclimate.com/github/increments/graphql-kaminari_connection/coverage)
[![license](https://img.shields.io/github/license/increments/graphql-kaminari_connection.svg)](https://github.com/increments/graphql-kaminari_connection/blob/master/LICENSE)


Kaminari based GraphQL pagination

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-kaminari_connection', require: 'graphql/kaminari_connection'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-kaminari_connection

## Usage

Include `GraphQL::KaminariConnection` to an object class:

```rb
class Types::Article < GraphQL::Schema::Object
  include GraphQL::KaminariConnection

  field :title, String, null: false
  field :body, String, null: false
end
```

then set `.kaminari_connection` to field type and resolve it as a kaminari object:

```rb
class Types::Query < GraphQL::Schema::Object
  field :articles, **ArticleType.kaminari_connection

  def articles(page: nil, per: nil)
    Article.all.page(page).per(per)
  end
end

class Schema < GraphQL::Schema
  query Types::Query
end
```

now, the `Schema`'s definition is:

```graphql
type Article {
  body: String!
  title: String!
}

type ArticlePage {
  items: [Article!]!
  pageData: PageData!
}

type PageData {
  currentPage: Int!
  isFirstPage: Boolean!
  isLastPage: Boolean!
  isOutOfRange: Boolean!
  limitValue: Int!
  nextPage: Int
  prevPage: Int
  totalPages: Int!
}

type Query {
  articles(page: Int, per: Int): ArticlePage!
}
```

### Additional arguments

You can define additional field arguments in its block:

```rb
class Types::Query < GraphQL::Schema::Object
  field(:articles, **ArticleType.kaminari_connection) do
    argument :scope, Types::ArticleScope, required: true
  end

  def articles(page: nil, per: nil, scope:)
    Article.public_send(scope).page(page).per(per)
  end
end
```

### Without COUNT

Give `{ without_count: true }` to `.kaminari_connection`:

```rb
class Types::Query < GraphQL::Schema::Object
  field :articles, **ArticleType.kaminari_connection(without_count: true)

  def articles(page: nil, per: nil)
    Article.all.page(page).per(per).without_count
  end
end
```

now schema definition contains:

```graphql
type ArticlePageWithoutTotalPages {
  items: [Article!]!
  pageData: PageDataWithoutTotalPages!
}

type PageDataWithoutTotalPages {
  currentPage: Int!
  isFirstPage: Boolean!
  isLastPage: Boolean!
  isOutOfRange: Boolean!
  limitValue: Int!
  nextPage: Int
  prevPage: Int
  # not have totalPages
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/increments/graphql-kaminari_connection. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Graphql::KaminariConnection project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/increments/graphql-kaminari_connection/blob/master/CODE_OF_CONDUCT.md).
