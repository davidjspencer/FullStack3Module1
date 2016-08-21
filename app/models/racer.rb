class Racer
	include ActiveModel::Model

	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	def initialize(params={})
    @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
    # reverse operation is
    # _id=>BSON::ObjectId.from_string(@id)
    @number=params[:number].to_i
    @first_name=params[:first_name]
    @last_name=params[:last_name]
    @gender=params[:gender]
    @group=params[:group]
    @secs=params[:secs].to_i
  end

  def persisted?
    !@id.nil?
  end

  def created_at
    nil
  end

  def updated_at
  	nil
  end


	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client['racers']
	end

	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)
		result=collection.find(prototype)
			.sort(sort)
			.skip(skip)
		result=result.limit(limit) if !limit.nil?
		return result

	end

	def self.find id
		result = self.collection.find(_id: BSON::ObjectId.from_string(id)).first
		#result = collection.find(:_id=>id).first
		return result.nil? ? nil : Racer.new(result)
	end

	def save
		result = self.class.collection.insert_one(id:@id, number:@number,
																							first_name:@first_name, 
																							last_name:@last_name, gender:@gender, 
																							group:@group, secs:@secs)
		@id = result.inserted_id.to_s
		return @id
	end

	def update(params)
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i

    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs) if !params.nil?
    self.class.collection.find(_id: BSON::ObjectId.from_string(@id)).update_one(params)
  end

  def destroy
  	self.class.collection
  						.find(_id: BSON::ObjectId.from_string(@id))
  						.delete_one
  end
end



