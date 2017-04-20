# frozen_string_literal: true

class CheckLineBusy
  attr_reader :client

  def initialize(client:)
    @client = client
  end

  def call
    find_in_progress_conferences
  end

  private

  def find_in_progress_conferences
    conferences = client.account.conferences
    in_progress_conference = conferences.list(status: 'in-progress').first
    in_progress_conference.participants.list.count == 2 if in_progress_conference
  end
end
