require 'spec_helper'

describe 'star_comments' do
  let(:msg) { '/* */ comment found' }

  context 'with fix disabled' do
    context 'multiline comment w/ one line of content' do
      let(:code) { "
        /* foo
        */
      "}

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(9)
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'multiline comment w/ no indents' do
      let(:code) { "/* foo *
 *     *
 * bar */"}

      let(:fixed) { "# foo *
# *
# bar"}

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'should convert the multiline comment' do
        expect(manifest).to eq(fixed)
      end
    end
 
    context 'multiline comment w/ one line of content' do
      let(:code) { "
        /* foo
        */
      "}

      let(:fixed) { "
        # foo
      "}

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_fixed(msg).on_line(2).in_column(9)
      end

      it 'should convert the multiline comment' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'multiline comment w/ multiple line of content' do
      let(:code) { "
        /* foo
         * bar
         * baz
         */
        notify { 'foo': }
      "}

      let(:fixed) { "
        # foo
        # bar
        # baz
        notify { 'foo': }
      "}

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_fixed(msg).on_line(2).in_column(9)
      end

      it 'should convert the multiline comment' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
