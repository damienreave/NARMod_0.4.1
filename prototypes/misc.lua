data:extend(
{
	-- TITANIUM AXE
	
	{
    type = "mining-tool",
    name = "titanium-axe",
    icon = "__NARMod__/graphics/icons/titanium-axe.png",
    flags = {"goes-to-main-inventory"},
    action =
    {
      type="direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
            type = "damage",
            damage = { amount = 14 , type = "physical"}
        }
      }
    },
    durability = 11000,
    subgroup = "tool",
    order = "a[mining]-e[titanium-axe]",
    speed = 11.5,
    stack_size = 10
  },
  
  {
    type = "recipe",
    name = "titanium-axe",
    enabled = false,
	energy_required= 5,
    ingredients =
    {
		{"titanium-plate", 5},
    },
	result = "titanium-axe"
	},
	
	{
		type = "decorative",
		name = "tf-overlay-green",
		flags = {"placeable-neutral", "not-on-map"},
		icon = "__NARMod__/graphics/entity/fieldmk2/tf-overlay-1.png",
		subgroup = "grass",
		order = "b[decorative]-b[tf-overlay-green]",
		collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selectable_in_game = false,
		render_layer = "radius-visualization",
		pictures =
		{
			{
				filename = "__NARMod__/graphics/entity/fieldmk2/tf-overlay-1.png",
				width = 32,
				height = 32,
				shift = {-0.5, -0.5}
			}
		}
	},
	
	{
		type = "decorative",
		name = "tf-overlay-red",
		flags = {"placeable-neutral", "not-on-map"},
		icon = "__NARMod__/graphics/entity/fieldmk2/tf-overlay-2.png",
		subgroup = "grass",
		order = "b[decorative]-b[tf-overlay-red]",
		collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selectable_in_game = false,
		render_layer = "radius-visualization",
		pictures =
		{
			{
				filename = "__NARMod__/graphics/entity/fieldmk2/tf-overlay-2.png",
				width = 32,
				height = 32,
				shift = {-0.5, -0.5}
			}
		}
	}
}
)