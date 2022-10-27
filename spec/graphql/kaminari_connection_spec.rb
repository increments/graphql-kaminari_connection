# frozen_string_literal: true

require 'graphql'
require 'kaminari'

RSpec.describe GraphQL::KaminariConnection do
  it 'has a version number' do
    expect(GraphQL::KaminariConnection::VERSION).not_to be nil
  end

  let(:schema) do
    query = query_type
    Class.new(GraphQL::Schema) do
      query query
    end
  end

  context 'with Kaminari::PaginatableArray' do
    let(:query_type) do
      foo_type = Class.new(GraphQL::Schema::Object) do
        include GraphQL::KaminariConnection
        graphql_name 'Foo'
        field :value, 'Int', null: false

        def value
          object
        end
      end

      Class.new(GraphQL::Schema::Object) do
        graphql_name 'Query'
        field :foos, foo_type.kaminari_connection

        def foos(page: nil, per: nil)
          Kaminari.paginate_array(1.upto(100).to_a).page(page).per(per)
        end
      end
    end

    it 'defines corresponding FooPage type' do
      expect(schema.to_definition).to include <<~GRAPHQL.strip
        type FooPage {
          """
          A list of items
          """
          items: [Foo!]!
          pageData: PageData!
        }
      GRAPHQL
    end

    it 'defines PageData type' do
      expect(schema.to_definition).to include <<~GRAPHQL.strip
        type PageData {
          currentPage: Int!
          isFirstPage: Boolean!
          isLastPage: Boolean!
          isOutOfRange: Boolean!
          limitValue: Int!
          nextPage: Int
          prevPage: Int
          totalCount: Int!
          totalPages: Int!
        }
      GRAPHQL
    end

    it 'defines a field with page and per arguments' do
      expect(schema.to_definition).to include <<~GRAPHQL.strip
        type Query {
          foos(page: Int, per: Int): FooPage!
        }
      GRAPHQL
    end

    it 'works' do
      query = <<~GRAPHQL
        query ($page: Int, $per: Int) {
          foos(page: $page, per: $per) {
            pageData {
              currentPage
              isFirstPage
              isLastPage
              isOutOfRange
              limitValue
              nextPage
              prevPage
              totalPages
            }
            items {
              value
            }
          }
        }
      GRAPHQL

      expect(schema.execute(query).to_h).to eq(
        'data' => {
          'foos' => {
            'pageData' => {
              'currentPage' => 1,
              'isFirstPage' => true,
              'isLastPage' => false,
              'isOutOfRange' => false,
              'limitValue' => 25,
              'nextPage' => 2,
              'prevPage' => nil,
              'totalPages' => 4
            },
            'items' => 1.upto(25).map { |value| { 'value' => value } }
          }
        }
      )

      expect(schema.execute(query, variables: { page: 2 }).to_h).to eq(
        'data' => {
          'foos' => {
            'pageData' => {
              'currentPage' => 2,
              'isFirstPage' => false,
              'isLastPage' => false,
              'isOutOfRange' => false,
              'limitValue' => 25,
              'nextPage' => 3,
              'prevPage' => 1,
              'totalPages' => 4
            },
            'items' => 26.upto(50).map { |value| { 'value' => value } }
          }
        }
      )

      expect(schema.execute(query, variables: { per: 20 }).to_h).to eq(
        'data' => {
          'foos' => {
            'pageData' => {
              'currentPage' => 1,
              'isFirstPage' => true,
              'isLastPage' => false,
              'isOutOfRange' => false,
              'limitValue' => 20,
              'nextPage' => 2,
              'prevPage' => nil,
              'totalPages' => 5
            },
            'items' => 1.upto(20).map { |value| { 'value' => value } }
          }
        }
      )

      expect(schema.execute(query, variables: { page: 3, per: 10 }).to_h).to eq(
        'data' => {
          'foos' => {
            'pageData' => {
              'currentPage' => 3,
              'isFirstPage' => false,
              'isLastPage' => false,
              'isOutOfRange' => false,
              'limitValue' => 10,
              'nextPage' => 4,
              'prevPage' => 2,
              'totalPages' => 10
            },
            'items' => 21.upto(30).map { |value| { 'value' => value } }
          }
        }
      )
    end
  end

  context 'with additional arguments' do
    let(:query_type) do
      foo_type = Class.new(GraphQL::Schema::Object) do
        include GraphQL::KaminariConnection
        graphql_name 'Foo'
        field :value, 'Int', null: false

        def value
          object
        end
      end

      Class.new(GraphQL::Schema::Object) do
        graphql_name 'Query'
        field(:foos, foo_type.kaminari_connection) do
          argument :max, 'Int', required: true
        end

        def foos(max:, page: nil, per: nil)
          Kaminari.paginate_array(1.upto(max).to_a).page(page).per(per)
        end
      end
    end

    it 'defines field with given arguments' do
      expect(schema.to_definition).to include <<~GRAPHQL.strip
        type Query {
          foos(max: Int!, page: Int, per: Int): FooPage!
        }
      GRAPHQL
    end

    it 'works' do
      query = <<~GRAPHQL
        query ($page: Int, $per: Int, $max: Int!) {
          foos(page: $page, per: $per, max: $max) {
            items {
              value
            }
          }
        }
      GRAPHQL

      expect(schema.execute(query, variables: { page: 2, per: 10, max: 15 }).to_h).to eq(
        'data' => {
          'foos' => {
            'items' => 11.upto(15).map { |value| { 'value' => value } }
          }
        }
      )
    end
  end

  context 'with .without_count' do
    let(:query_type) do
      post_type = Class.new(GraphQL::Schema::Object) do
        include GraphQL::KaminariConnection
        graphql_name 'Post'
        field :title, 'String', null: false
      end

      Class.new(GraphQL::Schema::Object) do
        graphql_name 'Query'
        field :posts, post_type.kaminari_connection(without_count: true)

        def posts(page: nil, per: nil)
          Post.all.page(page).per(per).without_count
        end
      end
    end

    it 'defines PostPageWithoutTotalPages type' do
      expect(schema.to_definition).to include <<~GRAPHQL.strip
        type PostPageWithoutTotalPages {
          """
          A list of items
          """
          items: [Post!]!
          pageData: PageDataWithoutTotalPages!
        }
      GRAPHQL
    end

    it 'defines PageDataWithoutTotalPages type' do
      expect(schema.to_definition).to include <<~GRAPHQL.strip
        type PageDataWithoutTotalPages {
          currentPage: Int!
          isFirstPage: Boolean!
          isLastPage: Boolean!
          isOutOfRange: Boolean!
          limitValue: Int!
          nextPage: Int
          prevPage: Int
        }
      GRAPHQL
    end

    it 'works' do
      Post.create([
                    { title: 'This Is A Pen' },
                    { title: 'GraphQL Is Awesome' }
                  ])

      query = <<~GRAPHQL
        {
          posts {
            pageData {
              currentPage
            }
            items {
              title
            }
          }
        }
      GRAPHQL

      expect(schema.execute(query).to_h).to match(
        'data' => {
          'posts' => {
            'pageData' => {
              'currentPage' => 1
            },
            'items' => match_array([
                                     { 'title' => 'This Is A Pen' },
                                     { 'title' => 'GraphQL Is Awesome' }
                                   ])
          }
        }
      )
    end
  end
end
