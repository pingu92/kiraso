local game_master_lib = require 'lib.game_master.game_master_lib'

local UnlockKingdomRecipeEncounter = class()

function UnlockKingdomRecipeEncounter:initialize()
   self._sv.ctx = nil
   self._sv.info = nil
end

--Unlock a recipe(s) on the current player, as defined by the json
function UnlockKingdomRecipeEncounter:start(ctx, info)
   assert(info.job and info.recipe_keys)
   self._sv.ctx = ctx
   self._sv.info = info

   -- get job
   local job_info = stonehearth.job:get_job_info(ctx.player_id, info.job)
   
   -- unlock recipe(s)
   for _, recipe_key in ipairs(info.recipe_keys) do
      job_info:manually_unlock_recipe(recipe_key)
   end
   
   ctx.arc:trigger_next_encounter(ctx)
end

--Stop
function UnlockKingdomRecipeEncounter:stop()
end

--Validate input
function UnlockKingdomRecipeEncounter:_unlock_recipes(job_info, recipe_keys)
   if type(recipe_keys) == 'table' then
      for _, recipe_key in ipairs(recipe_keys) do
         assert(type(recipe_key) == 'string', 'invalid key found in recipe_key table. entries must be strings')
         job_info:manually_unlock_recipe(recipe_key)
      end
   elseif type(recipe_keys) == 'string' then
      job_info:manually_unlock_recipe(recipe_keys)
   else
      assert(false, 'invalid recipe_key type. must be a string or table')
   end
end


--Destroy
function UnlockKingdomRecipeEncounter:destroy()
      self.__saved_variables:mark_changed()
end

--Destroy node
function UnlockKingdomRecipeEncounter:_destroy_node()
   self:destroy()
   game_master_lib.destroy_node(self._sv.ctx.encounter, self._sv.ctx.parent_node)
end

--On_Closed
function UnlockKingdomRecipeEncounter:_on_closed()
   self:_destroy_node()
end

return UnlockKingdomRecipeEncounter

--[[  How-To
<StonehearthEditor>
{
   "type" : "encounter",
   "encounter_type" : "unlock_kingdom_recipe",

   "in_edge"  : "<in edge>",

   "unlock_recipe_info" :  {
      "job" : "stonehearth:jobs:carpenter",
      "recipe_key" : [
	     "utility:first_recipe",
	     "utility:second_recipe",
	     "utility:third_recipe"
	  ]
   }
}
</StonehearthEditor>
]]