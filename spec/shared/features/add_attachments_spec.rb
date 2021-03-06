require 'spec_helper'

describe 'Add Attachment', type: :feature do
  let(:user) { create :user }
  let!(:category) { create :category }
  let!(:question) { create :question, author: user   }

  before :each do
    login_as user
  end

  after :each do
    Shared::Attachment.unscoped.each do |a|
      a.file.clear
      a.save
    end
  end

  it 'adds new question with attachment', js: true do
    visit shared.root_path

    click_link 'Opýtať sa otázku'

    attach_file('attachments[]', test_fixture_path('shared/attachments/image.ps'))

    click_button 'Opýtať'

    expect(page).to have_content('Prílohy – Súbor – musí byť obrázok, čistý text, PDF alebo PPT')

    visit shared.root_path

    click_link 'Opýtať sa otázku'

    fill_in 'question_title', with: 'Lorem ipsum title?'
    fill_in 'question_text',  with: 'Lorem ipsum'

    select2 category.name, from: 'question_category_id'

    attach_file('attachments[]', test_fixture_path('shared/attachments/image.jpg'))

    click_button 'Opýtať'

    expect(page).to have_content('Otázka bola úspešne pridaná.')

    expect(Shared::Attachment.count).to eq(1)

    within '.question-attachments' do
      expect(page).to have_content('image.jpg')
    end
  end

  it 'adds new answer with attachment' do
    visit shared.question_path(question)

    within '#question-answer' do
      attach_file('attachments[]', test_fixture_path('shared/attachments/image.ps'))

      click_button 'Odpovedať'
    end

    expect(page).to have_content('Prílohy – Súbor – musí byť obrázok, čistý text, PDF alebo PPT')

    within '#question-answer' do
      fill_in 'answer_text',  with: 'Lorem ipsum'

      attach_file('attachments[]', test_fixture_path('shared/attachments/image.jpg'))

      click_button 'Odpovedať'
    end

    expect(page).to have_content('Odpoveď bola úspešne pridaná.')

    expect(Shared::Answer.count).to eq(1)
    expect(Shared::Attachment.count).to eq(1)

    within '.answer-attachments' do
      expect(page).to have_content('image.jpg')
    end
  end

  context 'when updating a question' do
    it 'can attach file when updating a question' do
      visit shared.question_path(question)

      expect(Shared::Attachment.count).to eq(0)

      click_link "question-#{question.id}-edit-modal"

      within "#question-#{question.id}-editing" do
        attach_file('attachments[]', test_fixture_path('shared/attachments/image.jpg'))
        click_button 'Uložiť'
      end

      expect(Shared::Attachment.count).to eq(1)

      within '.question-attachments' do
        expect(page).to have_content('image.jpg')
      end
    end
  end
end
